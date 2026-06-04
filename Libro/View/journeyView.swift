//
//  journeyView.swift
//  Libro
//
//  Created by wessal hashim alharbi on 04/06/2026.
//

//
//  JourneyView.swift
//  Libro

import SwiftUI
import SwiftData

struct JourneyView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss

    // نجمع السيشنز ونرتبها من الأحدث للأقدم
    private var groupedSessions: [(String, [Session])] {
        guard let sessions = book.sessions else { return [] }

        let sorted = sessions
            .filter { $0.date != nil }
            .sorted { ($0.date ?? .now) > ($1.date ?? .now) }

        // نجمع بالتاريخ
        var groups: [(String, [Session])] = []
        var currentKey = ""
        var currentGroup: [Session] = []

        for session in sorted {
            let key = dateKey(session.date ?? .now)
            if key == currentKey {
                currentGroup.append(session)
            } else {
                if !currentGroup.isEmpty {
                    groups.append((currentKey, currentGroup))
                }
                currentKey = key
                currentGroup = [session]
            }
        }
        if !currentGroup.isEmpty {
            groups.append((currentKey, currentGroup))
        }

        return groups
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()

                if groupedSessions.isEmpty {
                    Text("لا توجد سيشنز بعد")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(groupedSessions.enumerated()), id: \.offset) { index, group in
                                TimelineGroup(
                                    dateLabel: group.0,
                                    sessions: group.1,
                                    isFirst: index == 0
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(book.bookName ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.medium)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .tint(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {} label: {
                        Image(systemName: "line.3.horizontal")
                            .fontWeight(.medium)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .tint(.primary)
                }
            }
        }
    }

    private func dateKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        return f.string(from: date)
    }
}

// MARK: - TimelineGroup (تاريخ + سيشنزه)

struct TimelineGroup: View {
    let dateLabel: String
    let sessions: [Session]
    let isFirst: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // ── الخط والنقطة ────────────────────────────────────
            VStack(spacing: 0) {
                Circle()
                    .fill(isFirst ? Color("darkbrown") : Color.gray.opacity(0.4))
                    .frame(width: 18, height: 18)

                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .padding(.top, 4)

            // ── المحتوى ──────────────────────────────────────────
            VStack(alignment: .leading, spacing: 12) {

                // التاريخ
                Text(dateLabel)
                    .font(.title3).fontWeight(.semibold)
                    .padding(.bottom, 4)

                // السيشنز
                ForEach(sessions) { session in
                    SessionCard(session: session)
                }

                Spacer().frame(height: 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - SessionCard

struct SessionCard: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // الاقتباس
            if let quote = session.quote, !quote.isEmpty {
                Text(quote)
                    .font(.body)
                    .foregroundStyle(Color.primary.opacity(0.8))
                    .lineSpacing(4)
            } else {
                Text("لا يوجد اقتباس")
                    .font(.body)
                    .foregroundStyle(.tertiary)
            }

            // المدة والصفحة
            HStack(spacing: 8) {
                // المدة
                if let duration = session.duration, duration > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(formatDuration(duration))
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)

                    Text("•").foregroundStyle(.secondary).font(.caption)
                }

                // الصفحة
                if let page = session.stoppedPage, page > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "bookmark")
                            .font(.caption)
                        Text("page \(page)")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // زر الـ options
                Button {} label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

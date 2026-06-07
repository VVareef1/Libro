//
//  JourneyView.swift
//  Libro

import SwiftUI
import SwiftData

struct JourneyView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss

    private var groupedSessions: [(String, [Session])] {
        guard let sessions = book.sessions else { return [] }
        let sorted = sessions
            .filter { $0.date != nil }
            .sorted { ($0.date ?? .now) > ($1.date ?? .now) }

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
                    Text("No sessions available")
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
            .navigationTitle(book.bookName ?? "").foregroundColor(Color("darkbrown"))
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button { dismiss() } label: {
//                        Image(systemName: "chevron.left")
//                            .fontWeight(.medium)
//                            .padding(10)
//                            .background(Color.white.opacity(0.8))
//                            .clipShape(Circle())
//                    }
//                    .tint(.primary)
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {} label: {
//                        Image(systemName: "line.3.horizontal")
//                            .fontWeight(.medium)
//                            .padding(10)
//                            .background(Color.white.opacity(0.8))
//                            .clipShape(Circle())
//                    }
//                    .tint(.primary)
//                }
//            }
        }
    }

    private func dateKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        return f.string(from: date)
    }
}

// MARK: - TimelineGroup

struct TimelineGroup: View {
    let dateLabel: String
    let sessions: [Session]
    let isFirst: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color("darkbrown"))
                    .frame(width: 18, height: 18)

                Rectangle()
                    .fill(Color(.gray.opacity(0.25)))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 12) {
                Text(dateLabel)
                    .font(.title3).foregroundColor(Color("darkbrown")).fontWeight(.semibold)
                    .padding(.bottom, 4)

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
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            // الكارد
            VStack(alignment: .leading, spacing: 12) {

                // الاقتباس
                if let quote = session.quote, !quote.isEmpty {
                    Text(quote)
                        .font(.body)
                        .foregroundColor(Color("darkbrown"))
                        .lineSpacing(4)
                        .lineLimit(isExpanded ? nil : 2)  // ← 2 سطر فقط أو كامل
                        .truncationMode(.tail)
                } else {
                    Text("No quote")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                }

                // المدة والصفحة
                HStack(spacing: 8) {
                    if let duration = session.duration, duration > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock").font(.caption)
                            Text(formatDuration(duration)).font(.caption)
                        }
                        .foregroundColor(Color("gray"))
                        Text("•").foregroundColor(Color("gray")).font(.caption)
                    }

                    if let page = session.stoppedPage, page > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bookmark").font(.caption)
                            Text("page \(page)").font(.caption)
                        }
                        .foregroundColor(Color("gray"))
                    }

                    Spacer()

                }
            }
            .padding(16)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .glassEffect(.regular.tint(.clear), in: RoundedRectangle(cornerRadius: 14))
            .onTapGesture {
                withAnimation(.spring(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }

            // Blur overlay لما يتوسع
            if isExpanded {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3)) {
                            isExpanded = false
                        }
                    }

                // الكارد الكبير فوق الـ blur
                VStack(alignment: .leading, spacing: 16) {
                    if let quote = session.quote, !quote.isEmpty {
                        Text(quote)
                            .font(.body)
                            .foregroundColor(Color("darkbrown"))
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack(spacing: 8) {
                        if let duration = session.duration, duration > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock").font(.caption)
                                Text(formatDuration(duration)).font(.caption)
                            }
                            .foregroundColor(Color("gray"))
                            Text("•").foregroundColor(Color("gray")).font(.caption)
                        }
                        if let page = session.stoppedPage, page > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "bookmark").font(.caption)
                                Text("page \(page)").font(.caption)
                            }
                            .foregroundColor(Color("gray"))
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .glassEffect(.regular.tint(.clear), in: RoundedRectangle(cornerRadius: 16))

              //  .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 8)
                .onTapGesture {
                    withAnimation(.spring(duration: 0.3)) {
                        isExpanded = false
                    }
                }
            }
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

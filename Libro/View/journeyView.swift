//
//  JourneyView.swift
//  Libro

import SwiftUI
import SwiftData

struct JourneyView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss

    // كل سيشن = عنصر منفصل في الـ timeline بغض النظر عن التاريخ
    private var sortedSessions: [Session] {
        (book.sessions ?? [])
            .filter { $0.date != nil }
            .sorted { ($0.date ?? .now) > ($1.date ?? .now) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()

                if sortedSessions.isEmpty {
                    Text("No sessions available")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(sortedSessions.enumerated()), id: \.offset) { index, session in
                                SessionTimelineRow(
                                    session: session,
                                    isFirst: index == 0,
                                    isLast: index == sortedSessions.count - 1
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
        }
    }
}

// MARK: - SessionTimelineRow (كل سيشن = صف في الـ timeline)

struct SessionTimelineRow: View {
    let session: Session
    let isFirst: Bool
    let isLast: Bool
    
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours   = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
    

    private var dateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        return f.string(from: session.date ?? .now)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // الخط والنقطة
            VStack(spacing: 0) {
                Circle()
                    .fill(isFirst ? Color("darkbrown") : Color.gray.opacity(0.4))
                    .frame(width: 18, height: 18)

                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.top, 4)

            // المحتوى
            VStack(alignment: .leading, spacing: 12) {

                // التاريخ
                Text(dateLabel)
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(Color("darkbrown"))
                    .padding(.bottom, 4)
                
                
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
                .padding(.bottom, 8)
                
                
                // كارد لكل quote منفصلة
                let quotes = session.quote ?? []
                let pages  = session.quotePageNumber ?? []

                if quotes.isEmpty {
                    QuoteCard(
                        quote: "",
                        page: session.stoppedPage ?? 0,
                        duration: session.duration ?? 0
                    )
                } else {
                    ForEach(Array(quotes.enumerated()), id: \.offset) { index, quote in
                        QuoteCard(
                            quote: quote,
                            page: index < pages.count ? pages[index] : (session.stoppedPage ?? 0),
                            duration:  0  // المدة بس بالكارد الأولى
                        )
                    }
                }

                Spacer().frame(height: 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - QuoteCard (كارد لكل quote)

struct QuoteCard: View {
    let quote: String
    let page: Int
    let duration: Int

    @State private var isExpanded = false

    var body: some View {
        ZStack {
            // الكارد العادي
            VStack(alignment: .leading, spacing: 12) {
                if !quote.isEmpty {
                    Text(quote)
                        .font(.body)
                        .foregroundColor(Color("darkbrown"))
                        .lineSpacing(4)
                        .lineLimit(isExpanded ? nil : 2)
                        .truncationMode(.tail)
                } else {
                    Text("No quote")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                }

                HStack(spacing: 8) {
                    if duration > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock").font(.caption)
                            Text(formatDuration(duration)).font(.caption)
                        }
                        .foregroundColor(Color("gray"))
                        Text("•").foregroundColor(Color("gray")).font(.caption)
                    }

                    if page > 0 {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .glassEffect(.regular.tint(.clear), in: RoundedRectangle(cornerRadius: 14))
            .onTapGesture {
                withAnimation(.spring(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }

            // Blur + كارد موسّع
            if isExpanded {
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3)) {
                            isExpanded = false
                        }
                    }

                VStack(alignment: .leading, spacing: 16) {
                    if !quote.isEmpty {
                        Text(quote)
                            .font(.body)
                            .foregroundColor(Color("darkbrown"))
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack(spacing: 8) {
                        if duration > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock").font(.caption)
                                Text(formatDuration(duration)).font(.caption)
                            }
                            .foregroundColor(Color("gray"))
                            Text("•").foregroundColor(Color("gray")).font(.caption)
                        }
                        if page > 0 {
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
        let hours   = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

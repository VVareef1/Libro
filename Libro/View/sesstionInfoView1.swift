//
//  BookSessionView1.swift
//  Libro

import SwiftUI
import SwiftData

struct BookSessionView1: View {

    let session: Session
    let book: Book

    @State private var currentPage = 0
    @State private var navigateToHome = false

    // نحول quote و quotePageNumber لـ array من tuples
    private var notes: [(text: String, page: Int)] {
        let quotes = session.quote ?? []
        let pages  = session.quotePageNumber ?? []
        return quotes.enumerated().map { (i, q) in
            (text: q, page: i < pages.count ? pages[i] : 0)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: session.date ?? .now)
    }

    private var formattedTime: String {
        let totalSeconds = session.duration ?? 0
        let hours   = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    Text(book.bookName ?? "")
                        .font(.system(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color("darkbrown"))
                        .padding(.top, 16)
                        .padding(.bottom, 32)

                    SessionInfoTimeline(
                        date: formattedDate,
                        timeSpent: formattedTime,
                        stoppedPage: session.stoppedPage ?? 0,
                        bookPages: book.totalPages
                    )
                    .padding(.horizontal, 20)

                    if !notes.isEmpty {
                        VStack(spacing: 12) {
                            ZStack {
                                // Side peek cards
                                ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                                    let offset = index - currentPage
                                    if abs(offset) == 1 {
                                        SwipeNoteCard(text: note.text, page: note.page)
                                            .frame(width: UIScreen.main.bounds.width - 80)
                                            .frame(height: 320)
                                            .scaleEffect(0.92)
                                            .offset(x: CGFloat(offset) * (UIScreen.main.bounds.width - 60))
                                            .zIndex(0)
                                    }
                                }

                                // Main swipeable TabView
                                TabView(selection: $currentPage) {
                                    ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                                        SwipeNoteCard(text: note.text, page: note.page)
                                            .frame(width: UIScreen.main.bounds.width - 80)
                                            .frame(height: 320)
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: 340)
                                .zIndex(1)
                            }

                            // Dots indicator
                            HStack(spacing: 6) {
                                ForEach(0..<notes.count, id: \.self) { i in
                                    Circle()
                                        .fill(i == currentPage
                                              ? Color("buttons")
                                              : Color("buttons").opacity(0.3))
                                        .frame(width: 7, height: 7)
                                }
                            }
                            .padding(.top, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.top, 32)
                    }

                    Spacer(minLength: 40)
                }
            }

            NavigationLink(
                destination: HomeView()
                    .navigationBarBackButtonHidden(true),
                isActive: $navigateToHome
            ) { EmptyView() }
        }
        .background(Color("background"))
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            HomeButton(action: { navigateToHome = true })
        }
    }
}

// MARK: - SwipeNoteCard

struct SwipeNoteCard: View {
    let text: String
    let page: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\u{201C}")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color("buttons"))
                .padding(.leading, 16)
                .padding(.top, 16)

            Spacer()

            Text(text)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(Color("darkbrown"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

            Spacer()

            Text("Page: \(page)")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color("gray"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(.regular.tint(Color(hex: "F2F2F2").opacity(0.3)), in: .rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

// MARK: - SessionInfoTimeline

struct SessionInfoTimeline: View {

    let date: String
    let timeSpent: String
    let stoppedPage: Int
    let bookPages: Int

    private let accentColor = Color("buttons")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            TimelineRow(
                icon: "calendar",
                label: "Date: \(date)",
                accentColor: accentColor,
                showConnector: true
            )

            TimelineRow(
                icon: "clock",
                label: "Time Spend: \(timeSpent)",
                accentColor: accentColor,
                showConnector: true
            )

            TimelineRow(
                icon: "bookmark",
                label: "Stopped Page\nNumber: \(stoppedPage)/\(bookPages)",
                accentColor: accentColor,
                showConnector: false
            )
        }
    }
}

// MARK: - TimelineRow

struct TimelineRow: View {

    let icon: String
    let label: String
    let accentColor: Color
    let showConnector: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color("buttons"))
                    .frame(width: 28, height: 28)

                if showConnector {
                    Rectangle()
                        .fill(Color(UIColor.separator))
                        .frame(width: 1.5)
                        .frame(height: 32)
                        .padding(.vertical, 4)
                }
            }

            Text(label)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color("darkbrown"))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)

            Spacer()
        }
    }
}

// MARK: - NoteCard

struct NoteCard: View {

    let text: String
    let page: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(alignment: .top, spacing: 0) {

                Rectangle()
                    .fill(Color("buttons"))
                    .frame(width: 3)
                    .cornerRadius(1.5)

                Text("\u{201C}\(text)\u{201D}")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("darkbrown"))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 12)
                    .padding(.vertical, 4)

                Spacer()
            }

            Text("Page: \(page)")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color("gray"))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .glassEffect(.regular.tint(Color(hex: "F2F2F2").opacity(0.3)), in: .rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

// MARK: - HomeButton

struct HomeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Home")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color("buttons"))
                .cornerRadius(27)
                .glassEffect()
        }
        .padding(.horizontal, 44)
        .padding(.bottom, 16)
        .padding(.top, 12)
        .background(Color("background"))
    }
}

// MARK: - Preview
//
//#Preview {
//    let container = try! ModelContainer(
//        for: Book.self, Session.self,
//        configurations: .init(isStoredInMemoryOnly: true)
//    )
//    let book = Book(bookName: "Book Name", bookImage: "", bookGoal: "Pages:30",
//                    reflection: "", bookRate: 0, status: "reading", totalPages: 350)
//    let session = Session(
//        timer: 0,
//        date: Date(),
//        duration: 8013,
//        stoppedPage: 20,
//        quote: ["Lorem ipsum dolor sit amet.", "Consectetur adipiscing elit."],
//        quotePageNumber: [38, 42]
//    )
//    session.book = book
//    container.mainContext.insert(book)
//    container.mainContext.insert(session)
//
//    BookSessionView1(session: session, book: book)
//        .modelContainer(container)
//}

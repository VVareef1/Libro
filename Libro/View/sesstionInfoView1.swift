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
        .background(Color(hex: "F2F2F2"))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
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

//
//  sesstionInfo1.swift
//  Libro
//

import SwiftUI

struct BookSessionView1: View {

    let session: BookSession
    let bookPages: Int
    @State private var currentPage = 0
    @State private var navigateToHome = false

    private let accentColor = Color("buttons")

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: session.date)
    }

    private var formattedTime: String {
        let totalSeconds = Int(session.timeSpent)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    Text(session.bookName)
                        .font(.system(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.darkbrown)
                        .padding(.top, 16)
                        .padding(.bottom, 32)

                    SessionInfoTimeline(
                        date: formattedDate,
                        timeSpent: formattedTime,
                        stoppedPage: session.stoppedPage,
                        bookPages: bookPages
                    )
                    .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        ZStack {
                            // Side peek cards
                            ForEach(Array(session.notes.enumerated()), id: \.offset) { index, note in
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
                                ForEach(Array(session.notes.enumerated()), id: \.offset) { index, note in
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
                            ForEach(0..<session.notes.count, id: \.self) { i in
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

                    Spacer(minLength: 40)
                }
            }

            // Navigate to HomeView and clear the stack
            NavigationLink(
                destination: HomeView()
                    .navigationBarBackButtonHidden(true),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
        }
        .background(Color("background"))
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            HomeButton(action: { navigateToHome = true })
        }
    }
}


struct SwipeNoteCard: View {

    let text: String
    let page: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Large quote mark top-left
            Text("\u{201C}")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color("buttons"))
                .padding(.leading, 16)
                .padding(.top, 16)

            Spacer()

            // Centered text
            Text(text)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(Color("darkbrown"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

            Spacer()

            // Page number bottom-right
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


#Preview {
    BookSessionView1(
        session: BookSession(
            bookName: "Book Name",
            date: DateComponents(calendar: .current, year: 2026, month: 4, day: 5).date ?? Date(),
            timeSpent: 8013,
            stoppedPage: 20,
            notes: [
                BookNote(text: "Lorem ipsum dolor sit amet.\nConsectetur adipiscing elit.", page: 38),
                BookNote(text: "Lorem ipsum dolor sit amet.\nConsectetur adipiscing elit.", page: 38),
                BookNote(text: "Lorem ipsum dolor sit amet.\nConsectetur adipiscing elit.", page: 38)
            ]
        ),
        bookPages: 350
    )
}

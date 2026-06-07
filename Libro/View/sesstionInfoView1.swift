////
////  sesstionInfo1.swift
////  Libro
////
//
//import SwiftUI
//
//struct BookSessionView1: View {
//
//    let session: BookSession
//    let bookPages: Int
//    @State private var currentPage = 0
//
//    private var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        return formatter.string(from: session.date)
//    }
//
//    private var formattedTime: String {
//        let totalSeconds = Int(session.timeSpent)
//        let hours = totalSeconds / 3600
//        let minutes = (totalSeconds % 3600) / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 0) {
//
//                Text(session.bookName)
//                    .font(.system(size: 28, weight: .bold))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.top, 16)
//                    .padding(.bottom, 32)
//
//                SessionInfoTimeline(
//                    date: formattedDate,
//                    timeSpent: formattedTime,
//                    stoppedPage: session.stoppedPage,
//                    bookPages: bookPages
//                )
//                .padding(.horizontal, 20)
//
//                VStack(spacing: 12) {
//                    TabView(selection: $currentPage) {
//                        ForEach(Array(session.notes.enumerated()), id: \.offset) { index, note in
//                            SwipeNoteCard(text: note.text, page: note.page)
//                                .padding(.horizontal, 24)
//                                .tag(index)
//                        }
//                    }
//                    .tabViewStyle(.page(indexDisplayMode: .never))
//                    .frame(height: 350)
//
//                    // Dots below cards
//                    HStack(spacing: 6) {
//                        ForEach(0..<session.notes.count, id: \.self) { i in
//                            Circle()
//                                .fill(i == currentPage
//                                    ? Color(red: 0.56, green: 0.42, blue: 0.28)
//                                    : Color(red: 0.56, green: 0.42, blue: 0.28).opacity(0.3))
//                                .frame(width: 7, height: 7)
//                        }
//                    }
//                }
//                .padding(.top, 32)
//
//                Spacer(minLength: 40)
//            }
//        }
//        .background(Color("background"))
//        .navigationBarBackButtonHidden(true)
//        .safeAreaInset(edge: .bottom) {
//            HomeButton(action: {})
//        }
//    }
//}
//
//
//struct SwipeNoteCard: View {
//
//    let text: String
//    let page: Int
//
//    private let accentColor = Color(red: 0.56, green: 0.42, blue: 0.28)
//
//    var body: some View {
//        VStack(alignment: .trailing, spacing: 8) {
//            HStack(alignment: .top, spacing: 0) {
//
//                Rectangle()
//                    .fill(accentColor)
//                    .frame(width: 3)
//                    .cornerRadius(1.5)
//
//                Text("\u{201C}\(text)\u{201D}")
//                    .font(.system(size: 28, weight: .regular))
//                    .foregroundColor(Color(UIColor.label))
//                    .fixedSize(horizontal: false, vertical: true)
//                    .padding(.leading, 16)
//                    .padding(.vertical, 16)
//                    .frame(maxWidth: .infinity/*, alignment: .leading*/)
//
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//
//            Text("Page: \(page)")
//                .font(.system(size: 14, weight: .bold))
//                .foregroundColor(Color(UIColor.secondaryLabel))
//                .padding(.trailing, 4)
//        }
//        .padding(.vertical, 20)
//        .padding(.horizontal, 16)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(hex: "F2F2F2"))
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
//    }
//}
//
//
//#Preview {
//    BookSessionView1(
//        session: BookSession(
//            bookName: "Book Name",
//            date: DateComponents(calendar: .current, year: 2026, month: 4, day: 5).date ?? Date(),
//            timeSpent: 8013,
//            stoppedPage: 20,
//            notes: [
//                BookNote(text: "Lorem ipsum dolor sit amet.\nConsectetur adipiscing elit.", page: 38),
//                BookNote(text: "Lorem ipsum dolor sit amet.\nConsectetur adipiscing elit.", page: 38),
//                BookNote(text: "Lorem ipsum dolor sit amet.\nConsectetur adipiscing elit.", page: 38)
//            ]
//        ),
//        bookPages: 350
//    )
//}

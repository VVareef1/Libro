//
//  sesstionInfo.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 14/05/2026.
//

import SwiftUI

struct BookSessionView: View {
 
    let session: BookSession
 
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
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
 
                Text(session.bookName)
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
 
                SessionInfoTimeline(
                    date: formattedDate,
                    timeSpent: formattedTime,
                    stoppedPage: session.stoppedPage
                )
                .padding(.horizontal, 20)
 
                VStack(spacing: 12) {
                    ForEach(session.notes) { note in
                        NoteCard(text: note.text, page: note.page)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
 
                Spacer(minLength: 40)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            HomeButton()
        }
    }
}
 
 
struct SessionInfoTimeline: View {
 
    let date: String
    let timeSpent: String
    let stoppedPage: Int
 
    private let accentColor = Color(red: 0.56, green: 0.42, blue: 0.28) 
 
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
                label: "Stopped Page\nNumber: \(stoppedPage)",
                accentColor: accentColor,
                showConnector: false
            )
        }
    }
}
 
 
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
                    .foregroundColor(accentColor)
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
                .foregroundColor(Color(UIColor.label))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
 
            Spacer()
        }
    }
}
 
 
struct NoteCard: View {
 
    let text: String
    let page: Int
 
    private let accentColor = Color(red: 0.56, green: 0.42, blue: 0.28)
 
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(alignment: .top, spacing: 0) {
 
                Rectangle()
                    .fill(accentColor)
                    .frame(width: 3)
                    .cornerRadius(1.5)
 
                Text(text)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 12)
                    .padding(.vertical, 4)
 
                Spacer()
            }
 
            Text("Page: \(page)")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
 
 
struct HomeButton: View {
 
    private let accentColor = Color(red: 0.56, green: 0.42, blue: 0.28)
 
    var body: some View {
        Button(action: {
        }) {
            Text("Home")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(accentColor)
                .cornerRadius(27)
        }
        .padding(.horizontal, 44)
        .padding(.bottom, 16)
        .padding(.top, 12)
        .background(Color(UIColor.systemGroupedBackground))
    }
}
 
 
#Preview {
    BookSessionView(
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
        )
    )
}

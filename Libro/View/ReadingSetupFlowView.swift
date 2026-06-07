//
//  ReadingSetupFlowView.swift
//  Libro
//
//  Created by Rana on 11/12/1447 AH.
//

import Foundation
import SwiftUI
import SwiftData

struct ReadingSetupFlowView: View {

    @Environment(\.modelContext) private var modelContext

    @State private var currentStep  = 1
    @State private var bookPages:   Int
    @State private var selectedGoal: String? = nil
    @State private var dailyPages  = 0
    @State private var hours       = 0
    @State private var minutes     = 15
    @State private var seconds     = 0

    let book:     GoogleBook
    let onFinish: () -> Void

    private let totalSteps = 3

    init(book: GoogleBook, onFinish: @escaping () -> Void) {
        self.book     = book
        self.onFinish = onFinish
        self._bookPages = State(initialValue: book.pageCount)
    }

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            VStack(spacing: 0) {

                ProgressHeaderView(
                    currentStep: $currentStep,
                    totalSteps: totalSteps
                ) {
                    // Skip → يحفظ ويروح للهوم
                    save()
                    onFinish()
                }

                switch currentStep {

                case 1:
                    BookPagesView(bookPages: bookPages) { pages in
                        bookPages = pages
                        currentStep += 1
                    }

                case 2:
                    GoalView(selectedGoal: $selectedGoal) {
                        currentStep += 1
                    }

                case 3:
                    if selectedGoal == "Pages" {
                        DailyPagesView(dailyPages: dailyPages) { pages in
                            dailyPages = pages
                            save()
                            onFinish()
                        }
                    } else {
                        DailyTimeView { h, m, s in
                            hours = h; minutes = m; seconds = s
                            save()
                            onFinish()
                        }
                    }

                default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - حفظ في SwiftData

    private func save() {

        // يحفظ الهدف مع القيمة
        // Pages → "Pages:30"
        // Time  → "Time:1800" (بالثواني)
        let goalValue: String
        if selectedGoal == "Pages" {
            goalValue = "Pages:\(dailyPages)"
        } else if selectedGoal == "Time" {
            let totalSeconds = (hours * 3600) + (minutes * 60) + seconds
            goalValue = "Time:\(totalSeconds)"
        } else {
            goalValue = ""
        }

        let newBook = Book(
            bookName:   book.title,
            bookImage:  book.thumbnailURL ?? "",
            bookGoal:   goalValue,
            reflection: "",
            bookRate:   0.0,
            status:     "reading",
            totalPages: bookPages
        )

        let library = Library(completedBooks: [], wishlistBooks: [])

        let user = User(userName: "", userIcon: "", streak: 0)
        user.books   = [newBook]
        user.library = library
        newBook.user = user
        library.user = user

        modelContext.insert(user)
        modelContext.insert(newBook)
        modelContext.insert(library)

        do {
            try modelContext.save()
            print("✅ Saved: goal = \(goalValue)")
        } catch {
            print("❌ Error saving: \(error)")
        }
    }
}

#Preview {
    ReadingSetupFlowView(
        book: GoogleBook(id: "1", title: "Atomic Habits", author: "James Clear", thumbnailURL: nil, pageCount: 320)
    ) {}
    .modelContainer(for: [User.self, Book.self, Library.self, Session.self, Journey.self], inMemory: true)
}

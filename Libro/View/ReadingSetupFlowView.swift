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

    @State private var currentStep = 1

    @State private var bookPages: Int
    @State private var selectedGoal: String? = nil
    @State private var dailyPages = 0
    @State private var hours = 0
    @State private var minutes = 15
    @State private var seconds = 0

    let book: GoogleBook
    let onFinish: () -> Void

    private let totalSteps = 4

    // للوصول للداتابيس
    @Environment(\.modelContext) private var modelContext

    init(book: GoogleBook, onFinish: @escaping () -> Void) {
        self.book = book
        self.onFinish = onFinish
        self._bookPages = State(initialValue: book.pageCount)
    }

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                ProgressHeaderView(
                    currentStep: $currentStep,
                    totalSteps: totalSteps
                ) {
                    saveAndFinish()
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
                            currentStep += 1
                        }
                    } else {
                        DailyTimeView { h, m, s in
                            hours = h
                            minutes = m
                            seconds = s
                            currentStep += 1
                        }
                    }

                case 4:
                    Color.clear.onAppear {
                        saveAndFinish()
                    }

                default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - حفظ البيانات

    private func saveAndFinish() {

        // 1. إنشاء الكتاب
        let newBook = Book(
            bookName:   book.title,
            bookImage:  book.thumbnailURL ?? "",
            bookGoal:   selectedGoal ?? "Pages",
            reflection: "",
            bookRate:   0.0,
            status:     "reading"
        )

        // 2. إنشاء المكتبة
        let library = Library(
            completedBooks: [],
            wishlistBooks:  []
        )

        // 3. إنشاء المستخدم وربط الكتاب والمكتبة
        let user = User(
            userName: "",
            userIcon: "",
            streak:   0
        )

        user.books   = [newBook]
        user.library = library
        newBook.user = user
        library.user = user

        // 4. حفظ في الداتابيس
        modelContext.insert(user)
        modelContext.insert(newBook)
        modelContext.insert(library)

        do {
            try modelContext.save()
            print("✅ تم الحفظ بنجاح")
        } catch {
            print("❌ خطأ في الحفظ: \(error)")
        }

        onFinish()
    }
}

#Preview {
    ReadingSetupFlowView(
        book: GoogleBook(
            id: "preview",
            title: "Atomic Habits",
            author: "James Clear",
            thumbnailURL: nil,
            pageCount: 320
        )
    ) {}
    .modelContainer(for: [User.self, Book.self, Library.self, Session.self, Journey.self])
}

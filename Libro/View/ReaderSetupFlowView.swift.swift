//
//  ReaderSetupFlowView.swift
//  Libro
//
//  Created by Rana on 11/12/1447 AH.
//

import Foundation
import SwiftUI
import SwiftData

struct ReaderSetupFlowView: View {

    @Environment(\.modelContext) private var modelContext

    @State private var currentStep:        Int        = 1
    @State private var selectedCategories: [String]   = []
    @State private var selectedBook:       GoogleBook?
    @State private var setupDone:          Bool       = false
    @State private var finalBook:          GoogleBook?

    private let totalSteps = 3

    var body: some View {

        if setupDone, let book = finalBook {
            HomeView(
                currentBook: book,
                selectedCategories: selectedCategories
            )

        } else {
            ZStack {
                Color("background")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    ProgressHeaderView(
                        currentStep: $currentStep,
                        totalSteps: totalSteps
                    ) {
                        currentStep = totalSteps + 1
                    }

                    switch currentStep {

                    case 1:
                        CategoryView { categories in
                            selectedCategories = categories
                            currentStep += 1
                        }

                    case 2:
                        RecommendationView(
                            selectedCategories: selectedCategories
                        ) { book in
                            selectedBook = book
                        }

                    default:
                        EmptyView()
                    }
                }
            }
            .fullScreenCover(item: $selectedBook) { book in
                ReadingSetupFlowView(book: book) {
                    saveBook(book: book)
                    finalBook = book
                    setupDone = true
                }
            }
        }
    }

    // MARK: - حفظ الكتاب في SwiftData

    private func saveBook(book: GoogleBook) {

        let newBook = Book(
            bookName:   book.title,
            bookImage:  book.thumbnailURL ?? "",
            bookGoal:   "",
            reflection: "",
            bookRate:   0.0,
            status:     "reading"
        )

        modelContext.insert(newBook)

        do {
            try modelContext.save()
            print("✅ Saved successfully")
        } catch {
            print("❌ Error saving: \(error)")
        }
    }
}

#Preview {
    ReaderSetupFlowView()
        .modelContainer(for: Book.self, inMemory: true)
}

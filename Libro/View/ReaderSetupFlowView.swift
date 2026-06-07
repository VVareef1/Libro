//
//  ReaderSetupFlowView.swift
//  Libro
//

import Foundation
import SwiftUI
import SwiftData

struct ReaderSetupFlowView: View {

    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    @State private var currentStep:        Int      = 1
    @State private var selectedCategories: [String] = []
    @State private var selectedBook:       GoogleBook?
    @State private var goHome:             Bool     = false

    private let totalSteps = 4   // 1: Reader  2: Category  3: Recommendation  4: ReadingSetup

    var body: some View {

        if goHome {
            HomeView()

        } else {
            ZStack {
                Color("background").ignoresSafeArea()

                VStack(spacing: 0) {

                    ProgressHeaderView(
                        currentStep: $currentStep,
                        totalSteps: totalSteps
                    ) {
                        hasCompletedSetup = true
                        goHome = true
                    }

                    switch currentStep {

                    case 1:
                        // ── Step 1: Choose a Reader ──────────────
                        ChooseReaderView {
                            currentStep += 1
                        }

                    case 2:
                        // ── Step 2: Categories ───────────────────
                        CategoryView { categories in
                            selectedCategories = categories
                            currentStep += 1
                        }

                    case 3:
                        // ── Step 3: Recommendation ───────────────
                        RecommendationView(
                            selectedCategories: selectedCategories
                        ) { book in
                            selectedBook = book
                            currentStep += 1
                        }

                    default:
                        EmptyView()
                    }
                }
            }
            .fullScreenCover(item: $selectedBook) { book in
                ReadingSetupFlowView(book: book, categories: selectedCategories) {
                    hasCompletedSetup = true
                    goHome = true
                }
            }
        }
    }
}

#Preview {
    ReaderSetupFlowView()
        .modelContainer(for: [User.self, Book.self, Library.self, Session.self, Journey.self], inMemory: true)
}

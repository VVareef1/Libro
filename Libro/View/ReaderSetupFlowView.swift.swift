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

    @State private var currentStep:        Int      = 1
    @State private var selectedCategories: [String] = []
    @State private var selectedBook:       GoogleBook?
    @State private var goHome:             Bool     = false

    private let totalSteps = 3

    var body: some View {

        if goHome {
            HomeView(selectedCategories: selectedCategories)

        } else {
            ZStack {
                Color("background").ignoresSafeArea()

                VStack(spacing: 0) {

                    ProgressHeaderView(
                        currentStep: $currentStep,
                        totalSteps: totalSteps
                    ) {
                        goHome = true
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
                            currentStep += 1  // ← هذا يحرك الـ flow للأمام
                        }

                    default:
                        EmptyView()
                    }
                }
            }
            .fullScreenCover(item: $selectedBook) { book in
                ReadingSetupFlowView(book: book) {
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

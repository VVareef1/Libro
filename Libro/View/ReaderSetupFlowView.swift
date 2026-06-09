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

    @State private var currentStep:        Int         = 1
    @State private var selectedCategories: [String]    = []
    @State private var selectedBook:       GoogleBook? = nil
    @State private var confirmedBook:      GoogleBook? = nil
    @State private var goHome:             Bool        = false

    private let totalSteps = 4

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
                        ChooseReaderView {
                            currentStep += 1
                        }

                    case 2:
                        CategoryView { categories in
                            selectedCategories = categories
                            saveCategories(categories)
                            currentStep += 1
                        }

                    case 3:
                        RecommendationView(
                            selectedCategories: selectedCategories,
                            confirmedBook: confirmedBook,
                            onSelect: { book in
                                selectedBook = book
                            },
                            onContinue: {
                                hasCompletedSetup = true
                                goHome = true
                            }
                        )

                    default:
                        EmptyView()
                    }
                }
            }
            .sheet(item: $selectedBook) { book in
                BookSearchDetailSheet(googleBook: book) {
                    confirmedBook = book
                    selectedBook  = nil
                }
            }
        }
    }

    // MARK: - Save Categories

    private func saveCategories(_ categories: [String]) {
        let descriptor = FetchDescriptor<User>()
        if let existingUser = try? modelContext.fetch(descriptor).first {
            // ✅ المستخدم موجود — فقط حدّث التصنيفات
            existingUser.categories = categories
        } else {
            // ✅ أنشئ مستخدم جديد بالتصنيفات
            let newUser = User(userName: "", userIcon: "", streak: 0)
            newUser.categories = categories
            let library = Library(completedBooks: [], wishlistBooks: [])
            newUser.library = library
            library.user = newUser
            modelContext.insert(newUser)
            modelContext.insert(library)
        }
        try? modelContext.save()
    }
}

#Preview {
    ReaderSetupFlowView()
        .modelContainer(for: [User.self, Book.self, Library.self, Session.self, Journey.self], inMemory: true)
}

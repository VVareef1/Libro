//
//  HomeView.swift
//  Libro
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @Query(filter: #Predicate<Book> { $0.status == "reading" })
    var readingBooks: [Book]

    var selectedCategories: [String] = []

    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    HomeHeaderView(greeting: viewModel.greetingText())
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    if readingBooks.isEmpty {
                        EmptyHomeView()
                    } else {

                        StreakCardView()
                            .padding(.horizontal, 20)
                            .padding(.top, 38)

                        SectionHeader(title: "Continue Reading")
                            .padding(.horizontal, 20)
                            .padding(.top, 45)

                        ContinueReadingCarousel(books: readingBooks)
                            .padding(.top, 14)

                        SectionHeader(title: "Recommended for you")
                            .padding(.horizontal, 20)
                            .padding(.top, 48)

                        if viewModel.isLoading {
                            SkeletonRecommendedScrollView()
                                .padding(.top, 14)
                        } else {
                            HomeRecommendedScrollView(books: viewModel.allRecommended)
                                .padding(.top, 14)
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color("background").ignoresSafeArea())
            .task {
                if !readingBooks.isEmpty {
                    await viewModel.loadBooks(for: selectedCategories)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(for: [User.self, Book.self, Library.self, Session.self, Journey.self], inMemory: true)
}

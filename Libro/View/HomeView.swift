//
//  HomeView.swift
//  Libro
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @Query(filter: #Predicate<Book> { $0.status == "reading" })
    var readingBooks: [Book]

    @Query var users: [User]

    @StateObject private var viewModel  = HomeViewModel()
    @State private var showAddBookSheet = false
    @State private var showManualAdd    = false
    @State private var showActionSheet  = false

    // ── sheet الاقتراحات ────────────────────────────────────
    @State private var selectedRecommended: GoogleBook? = nil

    private var selectedCategories: [String] {
        users.first?.categories ?? []
    }

    private var userBookTitles: Set<String> {
        Set(readingBooks.compactMap {
            $0.bookName?.trimmingCharacters(in: .whitespaces).lowercased()
        })
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        HomeHeaderView(greeting: viewModel.greetingText())
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                        if readingBooks.isEmpty {
                            EmptyHomeView(
                                onAddBook:   { showAddBookSheet = true },
                                onAddManual: { showManualAdd    = true }
                            )
                            .frame(height: UIScreen.main.bounds.height - 160)
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
                                let filtered = viewModel.allRecommended
                                    .filter {
                                        !userBookTitles.contains(
                                            $0.title.trimmingCharacters(in: .whitespaces).lowercased()
                                        )
                                    }
                                HomeRecommendedScrollView(books: filtered) { book in
                                    // ── فتح الـ sheet عند الضغط ──
                                    selectedRecommended = book
                                }
                                .padding(.top, 14)
                            }
                        }

                        Spacer(minLength: 100)
                    }
                }
                .background(Color("background").ignoresSafeArea())
                .task {
                    if !readingBooks.isEmpty && !selectedCategories.isEmpty {
                        await viewModel.loadBooks(for: selectedCategories)
                    }
                }

                if !readingBooks.isEmpty {
                    Button { showActionSheet = true } label: {
                        Circle()
                            .fill(Color(hex: "6B4C30"))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
                    .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
                        Button("Search for a Book") { showAddBookSheet = true }
                        Button("Add Manually")       { showManualAdd    = true }
                        Button("Cancel", role: .cancel) { }
                    }
                }
            }
        }
        // ── Search sheet ────────────────────────────────────
        .sheet(isPresented: $showAddBookSheet) {
            AddBookSheetView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        // ── Manual add sheet ────────────────────────────────
        .sheet(isPresented: $showManualAdd) {
            AddBookManualView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        // ── Recommended book sheet ──────────────────────────
        .sheet(item: $selectedRecommended) { book in
            BookSearchDetailSheet(googleBook: book) {
                selectedRecommended = nil
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }
}

// MARK: - Add Book Sheet (Search)

struct AddBookSheetView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedBook: GoogleBook?

    var body: some View {
        SearchBookView { book in
            selectedBook = book
        }
        .fullScreenCover(item: $selectedBook) { book in
            ReadingSetupFlowView(book: book, categories: []) {
                dismiss()
            }
        }
    }
}

// MARK: - Tab Bar Item

struct TabBarItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon + (isActive ? ".fill" : ""))
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? Color("darkbrown") : Color(.systemGray3))
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(isActive ? Color("darkbrown") : Color(.systemGray3))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(isActive ? Color(.systemGray6) : Color.clear)
                    .padding(.horizontal, 4)
            )
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(
            for: [User.self, Book.self, Library.self, Session.self, Journey.self],
            inMemory: true
        )
}

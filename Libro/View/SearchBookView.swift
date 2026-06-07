//
//  SearchBookView.swift
//  Libro
//

import SwiftUI

struct SearchBookView: View {

    let onSelect: (GoogleBook) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BooksViewModel()
    @State private var searchText      = ""

    // ── Sheet state ──────────────────────────────────────────
    @State private var selectedBook: GoogleBook? = nil
    @State private var showDetailSheet = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private var filteredBooks: [GoogleBook] {
        viewModel.allBooks
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HStack {
                Text("Search for a Book")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("darkbrown"))

                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("darkbrown"))
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            // MARK: - Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("gray"))
                    .font(.system(size: 16))

                TextField("Book name or author...", text: $searchText)
                    .font(.system(size: 15))
                    .foregroundColor(Color("darkbrown"))
                    .autocorrectionDisabled()

                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color("gray"))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect()
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // MARK: - Content
            if viewModel.isLoading {
                SkeletonGridView()

            } else if filteredBooks.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: "6B4C30").opacity(0.25))
                    Text("No results found")
                        .font(.system(size: 15))
                        .foregroundColor(Color("gray"))
                }
                Spacer()

            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredBooks) { book in
                            SearchBookCard(book: book) {
                                // ── فتح الـ sheet بدل onSelect مباشرة ──
                                selectedBook   = book
                                showDetailSheet = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color("background").ignoresSafeArea())
        .task { await viewModel.loadAllBooks() }
        .onChange(of: searchText) { _, newValue in
            Task {
                if newValue.count >= 2 {
                    await viewModel.searchBooks(query: newValue)
                } else if newValue.isEmpty {
                    await viewModel.loadAllBooks()
                }
            }
        }
        // ── Bottom Sheet ─────────────────────────────────────
        .sheet(item: $selectedBook) { book in
            BookSearchDetailSheet(googleBook: book) {
                // بعد الحفظ: نغلق SearchBookView كلها
                onSelect(book)
                dismiss()
            }
        }
    }
}

// MARK: - Search Book Card  (بدون تغيير)

struct SearchBookCard: View {
    let book:  GoogleBook
    let onTap: () -> Void

    private let cardW: CGFloat = (UIScreen.main.bounds.width - 56) / 3
    private var cardH: CGFloat { cardW * 1.5 }

    var body: some View {
        Button { onTap() } label: {
            VStack(alignment: .leading, spacing: 6) {
                coverView
                    .frame(width: cardW, height: cardH)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)

                Text(book.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("darkbrown"))
                    .lineLimit(2)
                    .frame(width: cardW, height: 32, alignment: .topLeading)

                Text(book.author)
                    .font(.system(size: 11))
                    .foregroundColor(Color("gray"))
                    .lineLimit(1)
                    .frame(width: cardW, alignment: .leading)
            }
            .frame(width: cardW)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var coverView: some View {
        if let url = URL(string: book.thumbnailURL ?? "") {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                default: placeholderCover
                }
            }
        } else {
            placeholderCover
        }
    }

    private var placeholderCover: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "E0D5C8"))
            .shimmer()
    }
}

// MARK: - Skeleton Grid  (بدون تغيير)

struct SkeletonGridView: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let cardW: CGFloat = (UIScreen.main.bounds.width - 60) / 3

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0..<9, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "E0D5C8"))
                            .frame(width: cardW, height: cardW * 1.45)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "E0D5C8"))
                            .frame(width: cardW * 0.8, height: 11)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "E0D5C8"))
                            .frame(width: cardW * 0.6, height: 10)
                            .shimmer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .allowsHitTesting(false)
    }
}

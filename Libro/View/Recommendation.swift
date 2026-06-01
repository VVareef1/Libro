//
//  RecommendationView.swift
//  Libro
//

import SwiftUI

struct RecommendationView: View {

    let selectedCategories: [String]
    let onContinue: (GoogleBook) -> Void

    @StateObject private var viewModel = BooksViewModel()
    @State private var selectedBook: GoogleBook?

    let checkColor = Color(hex: "78583C")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Books picked for you")                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color("darkbrown"))
                .padding(.horizontal, 24)
                .padding(.top, 52)

            Text("Pick at least 1 to continue")
                .font(.system(size: 15))
                .foregroundColor(Color("gray"))
                .padding(.horizontal, 24)
                .padding(.top, 12)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    }

                    BookSection(
                        title: "Recommended for you",
                        books: viewModel.recommendedBooks,
                        selectedBook: $selectedBook
                    )

                    BookSection(
                        title: "More Books you might like",
                        books: viewModel.moreBooks,
                        selectedBook: $selectedBook
                    )
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
            }

            Spacer(minLength: 0)

            Button {
                if let selectedBook {
                    onContinue(selectedBook)
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(selectedBook == nil ? Color("darkbrown").opacity(0.4) : .white)
                    .frame(width: 320, height: 58)
                    .background(
                        Group {
                            if selectedBook == nil {
                                Capsule().fill(.ultraThinMaterial)
                            } else {
                                Capsule().fill(checkColor)
                            }
                        }
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                selectedBook == nil ? Color.white.opacity(0.4) : Color.clear,
                                lineWidth: 0.5
                            )
                    )
            }
            .disabled(selectedBook == nil)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 34)
        }
        .background(Color("background").ignoresSafeArea())
        .task {
            await viewModel.loadBooks(for: selectedCategories)
        }
    }
}

struct BookSection: View {
    let title: String
    let books: [GoogleBook]
    @Binding var selectedBook: GoogleBook?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("darkbrown"))
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(books) { book in
                        BookCard(
                            book: book,
                            isSelected: selectedBook?.id == book.id
                        ) {
                            selectedBook = book
                        }
                    }
                }
                .padding(.leading, 24)
                .padding(.trailing, 24)
            }
        }
    }
}

struct BookCard: View {
    let book: GoogleBook
    let isSelected: Bool
    let onTap: () -> Void

    let checkColor = Color(hex: "78583C")
    let coverColor = Color(red: 0.75, green: 0.75, blue: 0.75)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            ZStack(alignment: .bottomTrailing) {

                if let thumbnailURL = book.thumbnailURL,
                   let url = URL(string: thumbnailURL) {

                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(coverColor)
                    }
                    .frame(width: 100, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(coverColor)
                        .frame(width: 100, height: 140)
                }

                ZStack {
                    if isSelected {
                        Circle()
                            .fill(checkColor)
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .fill(Color("background"))
                            .frame(width: 28, height: 28)
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(checkColor)
                    }
                }
                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                .padding(7)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                onTap()
            }

            Text(book.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("darkbrown"))
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)

            Text(book.author)
                .font(.system(size: 11))
                .foregroundColor(Color("gray"))
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    RecommendationView(selectedCategories: ["Fantasy"]) { selectedBook in
        
    }
}

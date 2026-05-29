//
//  RecommendationView.swift
//  Libro
//

import SwiftUI

// MARK: - Mock Data

struct BookItem: Identifiable {
    let id = UUID()
    let title: String
    let author: String
}

let mockBooks: [BookItem] = [
    BookItem(title: "Take Along Book", author: "John Steinbeck"),
    BookItem(title: "تأملات يومية", author: "ماركوس أوريليوس"),
    BookItem(title: "قصة الفن", author: "إرنست غومبريش"),
    BookItem(title: "Sapiens", author: "Yuval Noah Harari"),
    BookItem(title: "Atomic Habits", author: "James Clear"),
    BookItem(title: "The Alchemist", author: "Paulo Coelho"),
    BookItem(title: "Dune", author: "Frank Herbert"),
    BookItem(title: "1984", author: "George Orwell"),
]

// MARK: - Recommendation View

struct RecommendationView: View {

    @State private var selectedBooks: Set<UUID> = []
    let onContinue: () -> Void

    let recommended = Array(mockBooks.prefix(4))
    let moreLike    = Array(mockBooks.suffix(4))

    let checkColor = Color(hex: "78583C")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Title
            Text("Books picked for you")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color("darkbrown"))
                .padding(.horizontal, 24)
                .padding(.top, 52)

            // MARK: Subtitle
            Text("Pick at least 1 to continue")
                .font(.system(size: 15))
                .foregroundColor(Color("gray"))
                .padding(.horizontal, 24)
                .padding(.top, 12)

            // MARK: Scrollable Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    BookSection(
                        title: "Recommended for you",
                        books: recommended,
                        selectedBooks: $selectedBooks
                    )
                    BookSection(
                        title: "More Books you might like",
                        books: moreLike,
                        selectedBooks: $selectedBooks
                    )
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
            }

            Spacer(minLength: 0)

            // MARK: Continue Button
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(selectedBooks.isEmpty ? Color("darkbrown").opacity(0.4) : .white)
                    .frame(width: 320, height: 58)
                    .background(
                        Group {
                            if selectedBooks.isEmpty {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            } else {
                                Capsule()
                                    .fill(checkColor)
                            }
                        }
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                selectedBooks.isEmpty
                                    ? Color.white.opacity(0.4)
                                    : Color.clear,
                                lineWidth: 0.5
                            )
                    )
            }
            .disabled(selectedBooks.isEmpty)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 34)
            .animation(.spring(response: 0.3), value: selectedBooks.isEmpty)
        }
        .background(Color("background").ignoresSafeArea())
    }
}

// MARK: - Book Section

struct BookSection: View {
    let title: String
    let books: [BookItem]
    @Binding var selectedBooks: Set<UUID>

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
                            isSelected: selectedBooks.contains(book.id)
                        ) {
                            if selectedBooks.contains(book.id) {
                                selectedBooks.remove(book.id)
                            } else {
                                selectedBooks.insert(book.id)
                            }
                        }
                    }
                }
                .padding(.leading, 24)
                .padding(.trailing, 24)
            }
        }
    }
}

// MARK: - Book Card

struct BookCard: View {
    let book: BookItem
    let isSelected: Bool
    let onTap: () -> Void

    let checkColor = Color(hex: "78583C")
    let coverColor = Color(red: 0.75, green: 0.75, blue: 0.75)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(coverColor)
                    .frame(width: 100, height: 140)

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
            .onTapGesture { onTap() }
            .animation(.spring(response: 0.3), value: isSelected)

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

// MARK: - Color Hex Extension

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
    RecommendationView { }
}

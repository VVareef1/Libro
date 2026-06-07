//
//  LibraryView.swift
//  Libro

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(filter: #Predicate<Book> { $0.status == "finished" }) var books: [Book]
    @Query private var users: [User]

    @State private var selectedBook: Book?

    private var shelves: [[Book]] {
        stride(from: 0, to: books.count, by: 3).map {
            Array(books[$0 ..< min($0 + 3, books.count)])
        }
    }

    // صورة اليوزر من الداتابيس
    private var userImage: UIImage? {
        guard let icon = users.first?.userIcon, !icon.isEmpty else { return nil }
        if let img = UIImage(named: icon) { return img }
        if let data = Data(base64Encoded: icon) { return UIImage(data: data) }
        return nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if books.isEmpty {
                    Text("You haven't finished a book yet!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(shelves.enumerated()), id: \.offset) { _, shelf in
                                HStack(alignment: .bottom, spacing: 20) {
                                    ForEach(shelf) { book in
                                        BookCover(book: book)
                                            .onTapGesture { selectedBook = book }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Rectangle()
                                    .foregroundColor(Color("darkbrown"))
                                    .frame(height: 14)
                                    .padding(.bottom, 8)
                                    .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
                            }
                        }
                        .padding(.horizontal, 14)
                    }
                }
            }
            .background(Color("background").ignoresSafeArea())
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // أيقونة اليوزر
                    Circle()
                    .fill(Color(hex: "F0EDE8"))
                    .frame(width: 40, height: 40)
                        .overlay {
                            if let img = userImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .foregroundColor(Color(hex: "78583C").opacity(0.6))
                            }
                        }
                        .clipShape(Circle())
                }
            }
        }
    }

    // MARK: - BookCover

    struct BookCover: View {
        let book: Book

        private var coverImage: UIImage? {
            guard let name = book.bookImage, !name.isEmpty else { return nil }
            if let img = UIImage(named: name) { return img }
            if let data = Data(base64Encoded: name) { return UIImage(data: data) }
            return nil
        }

        var body: some View {
            Group {
                if let img = coverImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 95, height: 140)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.brown.opacity(0.7))
                        .frame(width: 95, height: 140)
                        .overlay(
                            Text(book.bookName ?? "")
                                .font(.caption).foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .padding(8)
                        )
                }
            }
            .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 3)
        }
    }
}

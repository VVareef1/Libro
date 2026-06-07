//
//  BooksViewModel.swift
//  Libro
//

import Foundation
import Combine

@MainActor
final class BooksViewModel: ObservableObject {

    @Published var recommendedBooks: [GoogleBook] = []
    @Published var moreBooks:        [GoogleBook] = []
    @Published var allBooks:         [GoogleBook] = []
    @Published var isLoading         = false
    @Published var errorMessage:     String?

    private let service = GoogleBooksService()

    func loadBooks(for categories: [String]) async {
        print("Selected Categories:", categories)
        isLoading = true
        errorMessage = nil

        do {
            let books = try await service.fetchBooks(for: categories)
            print("Books Count:", books.count)
            if let firstBook = books.first { print("First Book:", firstBook.title) }

            recommendedBooks = Array(books.prefix(6))
            moreBooks        = Array(books.dropFirst(6).prefix(10))
            allBooks         = books

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadAllBooks() async {
        guard allBooks.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            let categories = ["Fiction", "History", "Science", "Art", "Fantasy", "Business"]
            let books = try await service.fetchBooks(for: categories)
            allBooks = books
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

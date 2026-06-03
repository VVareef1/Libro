//
//  BooksViewModel.swift
//  Libro
//
//  Created by Rana on 15/12/1447 AH.
//

import Foundation
import Combine

@MainActor
final class BooksViewModel: ObservableObject {
    
    @Published var recommendedBooks: [GoogleBook] = []
    @Published var moreBooks: [GoogleBook] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = GoogleBooksService()
    
    func loadBooks(for categories: [String]) async {
        
        print("Selected Categories:", categories)

        isLoading = true
        errorMessage = nil

        do {
            let books = try await service.fetchBooks(for: categories)
            print("Books Count:", books.count)

            if let firstBook = books.first {
                print("First Book:", firstBook.title)
            }

            print("Books Count:", books.count)

            recommendedBooks = Array(books.prefix(6))
            moreBooks = Array(books.dropFirst(6).prefix(10))

        } catch {

            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

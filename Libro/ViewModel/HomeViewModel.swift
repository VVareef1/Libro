//
//  HomeViewModel.swift
//  Libro
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var recommendedBooks: [GoogleBook] = []
    @Published var moreBooks:        [GoogleBook] = []
    @Published var isLoading:        Bool         = false
    @Published var errorMessage:     String?

    private let service = GoogleBooksService()

    func loadBooks(for categories: [String]) async {
        guard !categories.isEmpty else { return }
        isLoading    = true
        errorMessage = nil
        do {
            let books        = try await service.fetchBooks(for: categories)
            recommendedBooks = Array(books.prefix(6))
            moreBooks        = Array(books.dropFirst(6).prefix(10))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    var allRecommended: [GoogleBook] {
        recommendedBooks + moreBooks
    }

    func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning,"
        case 12..<17: return "Good Afternoon,"
        default:      return "Good Evening,"
        }
    }
}

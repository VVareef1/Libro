//
//  GoogleBooksService.swift
//  Libro
//

import Foundation

final class GoogleBooksService {

    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    private let apiKey  = "AIzaSyDUwYtZeJpjjgG0qVNi2gpNngXQZyz0poA"

    func fetchBooks(for categories: [String]) async throws -> [GoogleBook] {
        var allBooks: [GoogleBook] = []
        for category in categories {
            let books = try await fetchBooksForQuery(category)
            allBooks.append(contentsOf: books)
        }
        return removeDuplicates(from: allBooks)
    }

    func searchBooks(query: String) async throws -> [GoogleBook] {
        let books = try await fetchBooksForQuery(query, maxResults: 40)
        return removeDuplicates(from: books)
    }

    private func fetchBooksForQuery(_ query: String, maxResults: Int = 10) async throws -> [GoogleBook] {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q",          value: query),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "printType",  value: "books"),
            URLQueryItem(name: "key",        value: apiKey)
        ]

        guard let url = components?.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

        return decoded.items?.compactMap { item in
            let info = item.volumeInfo
            return GoogleBook(
                id:           item.id,
                title:        info.title ?? "Unknown Title",
                author:       info.authors?.first ?? "Unknown Author",
                thumbnailURL: info.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://"),
                pageCount:    info.pageCount ?? 0
            )
        } ?? []
    }

    private func removeDuplicates(from books: [GoogleBook]) -> [GoogleBook] {
        var seenIDs  = Set<String>()
        var unique   = [GoogleBook]()
        for book in books {
            if seenIDs.insert(book.id).inserted { unique.append(book) }
        }
        return unique
    }
}

struct GoogleBooksResponse: Decodable { let items: [GoogleBookItem]? }
struct GoogleBookItem:      Decodable { let id: String; let volumeInfo: VolumeInfo }
struct VolumeInfo:          Decodable { let title: String?; let authors: [String]?; let pageCount: Int?; let imageLinks: ImageLinks? }
struct ImageLinks:          Decodable { let thumbnail: String? }

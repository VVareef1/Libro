//
//  GoogleBooksService.swift
//  Libro
//
//  Created by Rana on 15/12/1447 AH.
//

import Foundation

final class GoogleBooksService {
    
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    private let apiKey = "AIzaSyDUwYtZeJpjjgG0qVNi2gpNngXQZyz0poA"
    
    func fetchBooks(for categories: [String]) async throws -> [GoogleBook] {
        var allBooks: [GoogleBook] = []
        
        for category in categories {
            let books = try await fetchBooksForCategory(category)
            allBooks.append(contentsOf: books)
        }
        
        return removeDuplicates(from: allBooks)
    }
    
    private func fetchBooksForCategory(_ category: String) async throws -> [GoogleBook] {
        
        let query = category
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "10"),
            URLQueryItem(name: "printType", value: "books"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
        
        return decodedResponse.items?.compactMap { item in
            let info = item.volumeInfo
            
            return GoogleBook(
                id: item.id,
                title: info.title ?? "Unknown Title",
                author: info.authors?.first ?? "Unknown Author",
                thumbnailURL: info.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://"),
                pageCount: info.pageCount ?? 0
            )
        } ?? []
    }
    
    private func removeDuplicates(from books: [GoogleBook]) -> [GoogleBook] {
        var seenIDs: Set<String> = []
        var uniqueBooks: [GoogleBook] = []
        
        for book in books {
            if !seenIDs.contains(book.id) {
                seenIDs.insert(book.id)
                uniqueBooks.append(book)
            }
        }
        
        return uniqueBooks
    }
}

struct GoogleBooksResponse: Decodable {
    let items: [GoogleBookItem]?
}

struct GoogleBookItem: Decodable {
    let id: String
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Decodable {
    let title: String?
    let authors: [String]?
    let pageCount: Int?
    let imageLinks: ImageLinks?
}

struct ImageLinks: Decodable {
    let thumbnail: String?
}

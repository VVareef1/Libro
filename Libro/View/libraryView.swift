//
//  libraryView.swift
//  Libro
//
//  Created by wessal hashim alharbi on 04/06/2026.
//

//
//  ContentView.swift
//  Libro
//
//  Created by Wareef Saeed Alzahrani on 06/05/2026.
//

import SwiftUI
import SwiftData
 
struct LibraryView: View {
    @Query(filter: #Predicate<Book> { $0.status == "finished" }) var books: [Book]
    
    @State private var selectedBook: Book?
    
    // تقسيم الكتب: كل 3 في رف
    private var shelves: [[Book]] {
        stride(from: 0, to: books.count, by: 3).map {
            Array(books[$0 ..< min($0 + 3, books.count)])
        }
    }
    
    private let accentBrown = Color(red: 0.56, green: 0.42, blue: 0.28)

    
    var body: some View {
        

        if books.isEmpty {
            Text("You haven't finished a book yet!")
                .font(.headline)
                .foregroundStyle(.secondary)
        } else {
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(shelves.enumerated()), id: \.offset) { _, shelf in
                        
                        // الكتب
                        HStack(alignment: .bottom, spacing: 20) {
                            ForEach(shelf) { book in
                                BookCover(book: book)
                                    .onTapGesture { selectedBook = book }
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // الرف
                        Rectangle()
                            .fill(accentBrown)
                            .frame(height: 14)
                            .padding(.horizontal, 8)
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
                    }
                }
                .padding(.top, 30)
            }
            .background(Color("background"))
            .sheet(item: $selectedBook) { book in
                    BookDetailView(book: book)
            }
        }
    }
    
    // MARK: - غلاف الكتاب
    
    struct BookCover: View {
        let book: Book
        
        private var coverImage: UIImage? {
            guard let name = book.bookImage else { return nil }
            // أولاً يجرب Assets
            if let img = UIImage(named: name) { return img }
            // لو مو موجود يجرب base64
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
           // .rotationEffect(.degrees(Double(book.id.hashValue % 5) * 0.6 - 1.5))
        }
    }
    
    #Preview {
        let book = Book(bookName: "قصة الفن", bookImage: "book2", bookGoal: "", reflection: "", bookRate: 4.0, status: "finished")
        BookCover(book: book)
            .modelContainer(for: Book.self, inMemory: true)
    }
}

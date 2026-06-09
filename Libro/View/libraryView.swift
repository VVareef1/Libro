//
//  LibraryView.swift
//  Libro
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(filter: #Predicate<Book> { $0.status == "finished" }) var finishedBooks: [Book]
    @Query(filter: #Predicate<Book> { $0.status == "reading" })  var readingBooks:  [Book]
    @Query private var users: [User]

    @State private var selectedTab  = 0
    @State private var selectedBook: Book?

    private var currentBooks: [Book] {
        selectedTab == 0 ? readingBooks : finishedBooks
    }

    private var shelves: [[Book]] {
        stride(from: 0, to: currentBooks.count, by: 3).map {
            Array(currentBooks[$0 ..< min($0 + 3, currentBooks.count)])
        }
    }

    private var userImage: UIImage? {
        guard let icon = users.first?.userIcon, !icon.isEmpty else { return nil }
        if let img = UIImage(named: icon) { return img }
        if let data = Data(base64Encoded: icon) { return UIImage(data: data) }
        return nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Tabs
                HStack(spacing: 0) {
                    ForEach(["Reading", "Finished"], id: \.self) { tab in
                        let index = tab == "Reading" ? 0 : 1
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                selectedTab = index
                            }
                        } label: {
                            Text(tab)
                                .font(.system(size: 14, weight: selectedTab == index ? .semibold : .regular))
                                .foregroundColor(selectedTab == index ? .white : Color(hex: "78583C").opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(selectedTab == index ? Color(hex: "6B4C30") : Color.clear)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(Color(hex: "6B4C30").opacity(0.1))
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                // MARK: - Content
                Group {
                    if currentBooks.isEmpty {
                        VStack(spacing: 12) {
                            Text(selectedTab == 0 ? "No books in progress" : "You haven't finished a book yet!")
                                .font(.system(size: 15))
                                .foregroundColor(Color("gray"))
                        }
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
            }
            .background(Color("background").ignoresSafeArea())
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book)
            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Circle()
//                        .fill(Color(hex: "E8E0D8"))
//                        .frame(width: 40, height: 40)
//                        .overlay {
//                            if let img = userImage {
//                                Image(uiImage: img)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 36, height: 36)
//                                    .clipShape(Circle())
//                            } else {
//                                Image(systemName: "person.fill")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 20)
//                                    .foregroundColor(Color(hex: "78583C").opacity(0.6))
//                            }
//                        }
//                        .clipShape(Circle())
//                }
//            }
        }
    }

    // MARK: - BookCover

    struct BookCover: View {
        let book: Book

        // ✅ الإصلاح: يتحقق من نوع الصورة (base64 أو URL)
        private var isRemoteURL: Bool {
            guard let img = book.bookImage else { return false }
            return img.hasPrefix("http://") || img.hasPrefix("https://")
        }

        private var localImage: UIImage? {
            guard let name = book.bookImage, !name.isEmpty, !isRemoteURL else { return nil }
            if let img = UIImage(named: name) { return img }
            if let data = Data(base64Encoded: name) { return UIImage(data: data) }
            return nil
        }

        var body: some View {
            Group {
                if isRemoteURL, let urlStr = book.bookImage, let url = URL(string: urlStr) {
                    // صورة URL من الإنترنت
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(width: 95, height: 140)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        default:
                            placeholderCover
                        }
                    }
                } else if let img = localImage {
                    // صورة base64 (كتب يدوية أو محفوظة من السيرش)
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 95, height: 140)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    placeholderCover
                }
            }
            .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 3)
        }

        private var placeholderCover: some View {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "6B4C30").opacity(0.7))
                .frame(width: 95, height: 140)
                .overlay(
                    Text(book.bookName ?? "")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(8)
                )
        }
    }
}

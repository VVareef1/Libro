//
//  Homepage.swift
//  Libro
//
//  Created by Shaikha on 14/12/1447 AH.
//

import SwiftUI

// MARK: - Reading Book Model

struct ReadingBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let currentPage: Int
    let totalPages: Int
    var progress: Double { Double(currentPage) / Double(totalPages) }
    let coverColor: Color
    let thumbnailURL: String?
}

// MARK: - Home View

struct HomeView: View {

    let currentBook: GoogleBook
    let selectedCategories: [String]

    @StateObject private var viewModel = BooksViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                HomeHeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                StreakCardView()
                    .padding(.horizontal, 20)
                    .padding(.top, 38)

                SectionHeader(title: "Continue Reading")
                    .padding(.horizontal, 20)
                    .padding(.top, 45)

                ContinueReadingCard(book: ReadingBook(
                    title: currentBook.title,
                    author: currentBook.author,
                    currentPage: 0,
                    totalPages: currentBook.pageCount,
                    coverColor: Color(hex: "2D6E4E"),
                    thumbnailURL: currentBook.thumbnailURL
                ))
                .padding(.horizontal, 20)
                .padding(.top, 14)

                SectionHeader(title: "Recommended for you")
                    .padding(.horizontal, 20)
                    .padding(.top, 48)

                if viewModel.isLoading {
                    SkeletonRecommendedScrollView()
                        .padding(.top, 14)
                } else {
                    let allBooks = (viewModel.recommendedBooks + viewModel.moreBooks)
                        .filter { $0.id != currentBook.id }
                    HomeRecommendedScrollView(books: allBooks)
                        .padding(.top, 14)
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color("background").ignoresSafeArea())
        .task {
            await viewModel.loadBooks(for: selectedCategories)
        }
    }
}

// MARK: - Header

struct HomeHeaderView: View {
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: "F0EDE8"))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28)
                            .foregroundColor(Color(hex: "78583C").opacity(0.6))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Good Morning,")
                        .font(.system(size: 14))
                        .foregroundColor(Color("gray"))
                    Text("Reader")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color("darkbrown"))
                }
            }

            Spacer()

            Circle()
                .fill(Color(hex: "F0EDE8"))
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color("darkbrown"))
                )
        }
    }
}

// MARK: - Streak Card

struct StreakCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "6B4C30"))

            HStack(spacing: 16) {

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "F5A623"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("0 Days Streak")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Start reading to build your streak!")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("darkbrown"))
            Spacer()
            Button {
            } label: {
                HStack(spacing: 2) {
                    Text("See all")
                        .font(.system(size: 14))
                        .foregroundColor(Color("gray"))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color("gray"))
                }
            }
        }
    }
}

// MARK: - Continue Reading Card

struct ContinueReadingCard: View {
    let book: ReadingBook

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)

            HStack(spacing: 16) {

                Group {
                    if let thumbnailURL = book.thumbnailURL,
                       let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 10).fill(book.coverColor)
                        }
                        .frame(width: 90, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(book.coverColor)
                            .frame(width: 90, height: 120)
                            .overlay(
                                VStack {
                                    Spacer()
                                    Text(book.title)
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.85))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                        .padding(.bottom, 8)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("darkbrown"))
                        Text("by \(book.author)")
                            .font(.system(size: 13))
                            .foregroundColor(Color("gray"))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Page \(book.currentPage) of \(book.totalPages)")
                                .font(.system(size: 13))
                                .foregroundColor(Color("darkbrown").opacity(0.7))
                            Spacer()
                            Text("\(Int(book.progress * 100))%")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color("darkbrown"))
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(hex: "E0D5C8"))
                                    .frame(height: 6)
                                Capsule()
                                    .fill(Color(hex: "78583C"))
                                    .frame(width: geo.size.width * book.progress, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 130)
    }
}

// MARK: - Skeleton Loading

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.45),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: geo.size.width * phase)
                    .animation(
                        .linear(duration: 1.2).repeatForever(autoreverses: false),
                        value: phase
                    )
                }
                .clipped()
            )
            .onAppear { phase = 1 }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct SkeletonBookCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "E0D5C8"))
                .frame(width: 110, height: 155)
                .shimmer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "E0D5C8"))
                .frame(width: 90, height: 11)
                .shimmer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "E0D5C8"))
                .frame(width: 65, height: 10)
                .shimmer()
        }
    }
}

struct SkeletonRecommendedScrollView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(0..<6, id: \.self) { _ in
                    SkeletonBookCard()
                }
            }
            .padding(.horizontal, 20)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Home Recommended Scroll View

struct HomeRecommendedScrollView: View {
    let books: [GoogleBook]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(books) { book in
                    HomeRecommendedBookCard(book: book)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Home Recommended Book Card

struct HomeRecommendedBookCard: View {
    let book: GoogleBook

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let thumbnailURL = book.thumbnailURL,
                   let url = URL(string: thumbnailURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12).fill(Color(hex: "C4A96A"))
                    }
                    .frame(width: 110, height: 155)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "C4A96A"))
                        .frame(width: 110, height: 155)
                        .overlay(
                            VStack {
                                Spacer()
                                Text(book.title)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.85))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                    .padding(.bottom, 10)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)

            Text(book.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("darkbrown"))
                .lineLimit(2)
                .frame(width: 110, alignment: .leading)

            Text(book.author)
                .font(.system(size: 11))
                .foregroundColor(Color("gray"))
                .lineLimit(1)
                .frame(width: 110, alignment: .leading)
        }
    }
}


#Preview {
    HomeView(
        currentBook: GoogleBook(
            id: "preview",
            title: "Atomic Habits",
            author: "James Clear",
            thumbnailURL: nil,
            pageCount: 320
        ),
        selectedCategories: ["Self-Help", "Psychology"]
    )
}

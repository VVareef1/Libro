//
//  Homepage.swift
//  Libro
//
//  Created by Shaikha on 14/12/1447 AH.
//

//
//  HomeView.swift
//  Libro
//

//
//  HomeView.swift
//  Libro
//

import SwiftUI

// MARK: - Mock Data

struct ReadingBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let currentPage: Int
    let totalPages: Int
    var progress: Double { Double(currentPage) / Double(totalPages) }
    let coverColor: Color
}

struct RecommendedBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let coverColor: Color
}

let mockCurrentBook = ReadingBook(
    title: "Take Along a Book",
    author: "jhcbhgfvh",
    currentPage: 120,
    totalPages: 170,
    coverColor: Color(hex: "2D6E4E")
)

let mockRecommended: [RecommendedBook] = [
    RecommendedBook(title: "The Subtle Art of Not Giving a F*ck", author: "Mark Manson",   coverColor: Color(hex: "E84B1A")),
    RecommendedBook(title: "Al Ayam La Taqtulni",                  author: "Adonis",        coverColor: Color(hex: "5C4A1E")),
    RecommendedBook(title: "Fiqh Al-Nafs",                         author: "Abdullah Al-Ghathami", coverColor: Color(hex: "C4A96A")),
    RecommendedBook(title: "Adab Al-Zalam",                        author: "Elie Wiesel",   coverColor: Color(hex: "1A1F3A")),
]

let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]

// MARK: - Home View

struct HomeView: View {

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Header
                HomeHeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                // MARK: Streak Card
                StreakCardView()
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                // MARK: Continue Reading
                SectionHeader(title: "Continue Reading")
                    .padding(.horizontal, 20)
                    .padding(.top, 32)

                ContinueReadingCard(book: mockCurrentBook)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                // MARK: Recommended
                SectionHeader(title: "Recommended for you")
                    .padding(.horizontal, 20)
                    .padding(.top, 32)

                RecommendedScrollView(books: mockRecommended)
                    .padding(.top, 14)

                Spacer(minLength: 40)
            }
        }
        .background(Color("background").ignoresSafeArea())
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
                    Text("Sally")
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

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 46, height: 46)
                        Image(systemName: "flame.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "F5A623"))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("6 Days Streak")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Text("Keep it going!")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 18)
                .padding(.horizontal, 20)

                HStack(spacing: 0) {
                    ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                        VStack(spacing: 6) {
                            CandleView(isLit: index < 6)
                            Text(day)
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 8)
                .padding(.bottom, 18)
            }
        }
    }
}

// MARK: - Candle View

struct CandleView: View {
    let isLit: Bool

    var body: some View {
        ZStack(alignment: .top) {
            // Flame
            if isLit {
                ZStack {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "FFD966"), Color(hex: "F5A623").opacity(0.6), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 10
                            )
                        )
                        .frame(width: 18, height: 18)
                        .offset(y: -8)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "FFD966"))
                        .offset(y: -6)
                }
            } else {
                Color.clear.frame(width: 18, height: 18).offset(y: -8)
            }

            // Candle body
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(isLit ? 0.9 : 0.35))
                .frame(width: 12, height: 32)
                .offset(y: 10)

            // Base
            Capsule()
                .fill(Color.white.opacity(isLit ? 0.5 : 0.2))
                .frame(width: 18, height: 5)
                .offset(y: 37)
        }
        .frame(width: 28, height: 52)
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
                // Book cover
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(book.coverColor)
                        .frame(width: 90, height: 120)

                    // Simple decorative lines simulating book cover
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 60, height: 3)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 3)
                    }
                    .offset(y: 20)

                    Text("Take along a\nBOOK")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .offset(y: 34)
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

// MARK: - Recommended Scroll View

struct RecommendedScrollView: View {
    let books: [RecommendedBook]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(books) { book in
                    RecommendedBookCard(book: book)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Recommended Book Card

struct RecommendedBookCard: View {
    let book: RecommendedBook

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(book.coverColor)
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
    HomeView()
}

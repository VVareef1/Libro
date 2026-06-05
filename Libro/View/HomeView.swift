//
//  HomeView.swift
//  Libro
//

import SwiftUI
import SwiftData

// MARK: - Reading Book Model

struct ReadingBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let currentPage: Int
    let totalPages: Int
    var progress: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }
    let coverColor: Color
    let thumbnailURL: String?
}

// MARK: - Home View

struct HomeView: View {

    @Query(filter: #Predicate<Book> { $0.status == "reading" })
    var readingBooks: [Book]

    var selectedCategories: [String] = []

    @StateObject private var viewModel = BooksViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                HomeHeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                if readingBooks.isEmpty {
                    EmptyHomeView()
                } else {

                    StreakCardView()
                        .padding(.horizontal, 20)
                        .padding(.top, 38)

                    SectionHeader(title: "Continue Reading")
                        .padding(.horizontal, 20)
                        .padding(.top, 45)

                    ContinueReadingCarousel(books: readingBooks)
                        .padding(.top, 14)

                    SectionHeader(title: "Recommended for you")
                        .padding(.horizontal, 20)
                        .padding(.top, 48)

                    if viewModel.isLoading {
                        SkeletonRecommendedScrollView()
                            .padding(.top, 14)
                    } else {
                        let allBooks = (viewModel.recommendedBooks + viewModel.moreBooks)
                        HomeRecommendedScrollView(books: allBooks)
                            .padding(.top, 14)
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color("background").ignoresSafeArea())
        .task {
            if !readingBooks.isEmpty && !selectedCategories.isEmpty {
                await viewModel.loadBooks(for: selectedCategories)
            }
        }
    }
}

// MARK: - Continue Reading Carousel

struct ContinueReadingCarousel: View {
    let books: [Book]

    // عرض الكارد = عرض الشاشة - 20 (padding يسار) - 20 (padding يمين) - 20 (كشف الكارد التالي)
    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 60
    private let spacing: CGFloat = 14

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(books) { book in
                    ContinueReadingCard(book: ReadingBook(
                        title: book.bookName ?? "",
                        author: "",
                        currentPage: 0,
                        totalPages: 0,
                        coverColor: Color(hex: "2D6E4E"),
                        thumbnailURL: book.bookImage
                    ))
                    .frame(width: cardWidth)
                    .scrollTransition(.animated(.spring(response: 0.4, dampingFraction: 0.82))) { content, phase in
                        content
                            .scaleEffect(
                                y: phase.isIdentity ? 1.0 : 0.88,
                                anchor: .center
                            )
                            .opacity(phase.isIdentity ? 1.0 : 0.55)
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.leading, 20)   // يتوافق مع padding العناوين
            .padding(.trailing, 20)
            .padding(.vertical, 8)
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 150)
    }
}

// MARK: - Empty Home

struct EmptyHomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 80)

            Image(systemName: "books.vertical")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "6B4C30").opacity(0.3))

            VStack(spacing: 8) {
                Text("Start your reading Journey")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("darkbrown"))
                    .multilineTextAlignment(.center)

                Text("Add some books so you can get started")
                    .font(.system(size: 15))
                    .foregroundColor(Color("gray"))
                    .multilineTextAlignment(.center)
            }

            Button { } label: {
                Text("Add Book")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 280, height: 56)
                    .background(Color(hex: "6B4C30"))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
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
            Button { } label: {
                HStack(spacing: 2) {
                    Text("See all").font(.system(size: 14))
                    Image(systemName: "chevron.right").font(.system(size: 12))
                }
                .foregroundColor(Color("gray"))
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
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 120)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            default:
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(book.coverColor)
                                    .frame(width: 90, height: 120)
                            }
                        }
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
                .frame(width: 90, height: 120)
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("darkbrown"))
                            .lineLimit(2)
                        if !book.author.isEmpty {
                            Text("by \(book.author)")
                                .font(.system(size: 13))
                                .foregroundColor(Color("gray"))
                        }
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
                                Capsule().fill(Color(hex: "E0D5C8")).frame(height: 6)
                                Capsule().fill(Color(hex: "78583C"))
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

// MARK: - Skeleton

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.white.opacity(0), .white.opacity(0.45), .white.opacity(0)],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: geo.size.width * phase)
                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: phase)
                }
                .clipped()
            )
            .onAppear { phase = 1 }
    }
}

extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

struct SkeletonBookCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12).fill(Color(hex: "E0D5C8"))
                .frame(width: 110, height: 155).shimmer()
            RoundedRectangle(cornerRadius: 4).fill(Color(hex: "E0D5C8"))
                .frame(width: 90, height: 11).shimmer()
            RoundedRectangle(cornerRadius: 4).fill(Color(hex: "E0D5C8"))
                .frame(width: 65, height: 10).shimmer()
        }
    }
}

struct SkeletonRecommendedScrollView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(0..<6, id: \.self) { _ in SkeletonBookCard() }
            }
            .padding(.horizontal, 20)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Recommended

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

struct HomeRecommendedBookCard: View {
    let book: GoogleBook

    private let cardW: CGFloat = 95
    private let cardH: CGFloat = 135

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let thumbnailURL = book.thumbnailURL, let url = URL(string: thumbnailURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: cardW, height: cardH)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        default:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "C4A96A"))
                                .frame(width: cardW, height: cardH)
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "C4A96A"))
                        .frame(width: cardW, height: cardH)
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
            .frame(width: cardW, height: cardH)  // حجم ثابت لكل الحالات
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)

            Text(book.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("darkbrown"))
                .lineLimit(2)
                .frame(width: cardW, alignment: .leading)

            Text(book.author)
                .font(.system(size: 11))
                .foregroundColor(Color("gray"))
                .lineLimit(1)
                .frame(width: cardW, alignment: .leading)
        }
        .frame(width: cardW)  // يضمن أن كل الكاردات بنفس العرض
    }
}


// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(for: [User.self, Book.self, Library.self, Session.self, Journey.self], inMemory: true)
}

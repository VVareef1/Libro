//
//  HomeSubViews.swift
//  Libro
//

import SwiftUI
import SwiftData

// MARK: - Header

struct HomeHeaderView: View {
    let greeting: String

    @Query private var users: [User]

    private var currentUser: User? { users.first }

    private var userImage: UIImage? {
        guard let icon = currentUser?.userIcon, !icon.isEmpty else { return nil }
        if let img = UIImage(named: icon) { return img }
        if let data = Data(base64Encoded: icon) { return UIImage(data: data) }
        return nil
    }

    private let buttonSize: CGFloat = 46
    private let iconSize:   CGFloat = 20

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: "E8E0D8").opacity(0.01))
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay {
                        if let img = userImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: buttonSize + 10, height: buttonSize + 30)
                                .clipped()
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconSize)
                                .foregroundColor(Color(hex: "78583C").opacity(0.6))
                        }
                    }
                    .clipShape(Circle())
                    .glassEffect(.regular.tint(Color(hex: "E8E0D8").opacity(0.3)), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "78583C").opacity(0.6))
                    Text(currentUser?.userName ?? "Reader")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color("darkbrown"))
                }
            }
            Spacer()

            NavigationLink(destination: LibraryView()) {
                Circle()
                    .fill(Color(hex: "E8E0D8").opacity(0.01))
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Image(systemName: "books.vertical.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize)
                            .foregroundColor(Color(hex: "3E2F2A"))
                    )
                    .clipShape(Circle())
                    .glassEffect(.regular.tint(Color(hex: "E8E0D8").opacity(0.3)), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Streak Card

struct StreakCardView: View {

    @Query var users: [User]

    private var user: User? { users.first }
    private var streak: Int { user?.streak ?? 0 }

    private var isStreakLost: Bool {
        guard let last = user?.lastStreakDate else { return false }
        let cal = Calendar.current
        return !cal.isDateInToday(last) && !cal.isDateInYesterday(last)
    }

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
                        .foregroundColor(
                            isStreakLost
                                ? Color(hex: "F5A623").opacity(0.35)
                                : Color(hex: "F5A623")
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    if isStreakLost {
                        Text("Streak Lost")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Open a book to start a new streak!")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    } else if streak == 0 {
                        Text("0 Days Streak")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Start reading to build your streak!")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("\(streak) Days Streak")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Keep it going!")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .onAppear { resetStreakIfNeeded() }
    }

    private func resetStreakIfNeeded() {
        guard isStreakLost else { return }
        user?.streak = 0
        user?.lastStreakDate = nil
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
        }
    }
}

// MARK: - Empty State

struct EmptyHomeView: View {
    var onAddBook: () -> Void
    var onAddManual: () -> Void

    @State private var showActionSheet = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 24) {
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

                Button { showActionSheet = true } label: {
                    Text("Add Book")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "6B4C30"))
                        .clipShape(Capsule())
                }
                .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
                    Button("Search for a Book") { onAddBook() }
                    Button("Add Manually") { onAddManual() }
                    Button("Cancel", role: .cancel) { }
                }
            }
            .padding(.horizontal, 20)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
}

// MARK: - Continue Reading Carousel

struct ContinueReadingCarousel: View {
    let books: [Book]
    var onBookTap: (Book) -> Void

    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 60
    private let spacing:   CGFloat = 14

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(books) { book in
                    Button {
                        onBookTap(book)
                    } label: {
                        ContinueReadingCard(book: ReadingBook(
                            title:        book.bookName   ?? "",
                            author:       book.bookAuthor ?? "",
                            currentPage:  book.currentPage,
                            totalPages:   book.totalPages,
                            coverColor:   Color(hex: "2D6E4E"),
                            thumbnailURL: book.bookImage
                        ))
                        .frame(width: cardWidth)
                    }
                    .buttonStyle(.plain)
                    .scrollTransition(.animated(.spring(response: 0.4, dampingFraction: 0.82))) { content, phase in
                        content
                            .scaleEffect(y: phase.isIdentity ? 1.0 : 0.88, anchor: .center)
                            .opacity(phase.isIdentity ? 1.0 : 0.55)
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 150)
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
                coverView
                    .frame(width: 90, height: 120)
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

                infoView
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 130)
    }

    @ViewBuilder
    private var coverView: some View {
        if let urlStr = book.thumbnailURL, !urlStr.isEmpty {
            if !urlStr.hasPrefix("http"),
               let data = Data(base64Encoded: urlStr),
               let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                            .frame(width: 90, height: 120)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        placeholderCover
                    }
                }
            } else {
                placeholderCover
            }
        } else {
            placeholderCover
        }
    }

    private var placeholderCover: some View {
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

    private var infoView: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("darkbrown"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.8)
                if !book.author.isEmpty {
                    Text("by \(book.author)")
                        .font(.system(size: 13))
                        .foregroundColor(Color("gray"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            Spacer()
            progressView
        }
    }

    private var progressView: some View {
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
}

// MARK: - Shimmer

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
    var onBookTap: (GoogleBook) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(books) { book in
                    HomeRecommendedBookCard(book: book) {
                        onBookTap(book)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct HomeRecommendedBookCard: View {
    let book:  GoogleBook
    var onTap: () -> Void

    private let cardW: CGFloat = 105

    var body: some View {
        Button { onTap() } label: {
            VStack(alignment: .leading, spacing: 6) {
                coverView
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)

                Text(book.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("darkbrown"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: cardW, alignment: .topLeading)

                Text(book.author)
                    .font(.system(size: 11))
                    .foregroundColor(Color("gray"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: cardW, alignment: .leading)
            }
            .frame(width: cardW)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var coverView: some View {
        if let url = URL(string: book.thumbnailURL ?? "") {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                        .frame(width: cardW, height: 148)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .empty, .failure:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "E0D5C8"))
                        .frame(width: cardW, height: 148)
                        .shimmer()
                @unknown default:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "E0D5C8"))
                        .frame(width: cardW, height: 148)
                        .shimmer()
                }
            }
        } else {
            placeholderCover
        }
    }

    private var placeholderCover: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "C4A96A"))
            .frame(width: cardW, height: 148)
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

// MARK: - Reading Book Model

struct ReadingBook: Identifiable {
    let id           = UUID()
    let title:        String
    let author:       String
    let currentPage:  Int
    let totalPages:   Int
    var progress: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }
    let coverColor:   Color
    let thumbnailURL: String?
}

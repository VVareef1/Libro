//
//  BookSearchDetailSheet.swift
//  Libro
//

import SwiftUI
import SwiftData

// MARK: - BookSearchDetailSheet

struct BookSearchDetailSheet: View {

    let googleBook: GoogleBook
    let onSave: () -> Void

    @Environment(\.dismiss)      private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Pre-filled from GoogleBook
    @State private var bookName:   String
    @State private var bookAuthor: String
    @State private var totalPages: String = ""

    // Cover loaded async
    @State private var coverImage: UIImage? = nil
    @State private var isLoadingCover = true

    // Reading Goal
    @State private var goalType   = "Pages"
    @State private var dailyPages = 5
    @State private var hours      = 0
    @State private var minutes    = 30
    @State private var seconds    = 0

    private let brown = Color(hex: "6B4C30")
    private var canSave: Bool { !bookName.isEmpty }

    // MARK: init
    init(googleBook: GoogleBook, onSave: @escaping () -> Void) {
        self.googleBook = googleBook
        self.onSave     = onSave
        _bookName   = State(initialValue: googleBook.title)
        _bookAuthor = State(initialValue: googleBook.author)
        // Pre-fill pages from GoogleBook if available
        let pages = googleBook.pageCount ?? 0
        _totalPages = State(initialValue: pages > 0 ? "\(pages)" : "")
    }

    // MARK: Body
    var body: some View {
        ZStack(alignment: .top) {

            // ── Background blobs ─────────────────────────────────
            Color("background").ignoresSafeArea()

            Circle()
                .fill(Color(hex: "C4956A"))
                .frame(width: 220, height: 220)
                .blur(radius: 60).opacity(0.35)
                .offset(x: -100, y: -80).ignoresSafeArea()

            Circle()
                .fill(Color(hex: "8B5E3C"))
                .frame(width: 180, height: 180)
                .blur(radius: 60).opacity(0.35)
                .offset(x: 120, y: 60).ignoresSafeArea()

            Circle()
                .fill(Color(hex: "D4A876"))
                .frame(width: 160, height: 160)
                .blur(radius: 55).opacity(0.30)
                .offset(x: -80, y: 320).ignoresSafeArea()

            // ── Scrollable content ───────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {

                    // ── Cover ────────────────────────────────────
                    ZStack {
                        if isLoadingCover {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .frame(width: 130, height: 185)
                                .shimmer()
                        } else if let img = coverImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 130, height: 185)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.28), radius: 16, y: 8)
                                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .frame(width: 130, height: 185)
                                .overlay(
                                    Image(systemName: "book.closed")
                                        .font(.system(size: 32))
                                        .foregroundStyle(brown.opacity(0.4))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.white.opacity(0.65), .white.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                    .frame(width: 130, height: 185)
                    .frame(maxWidth: .infinity)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isLoadingCover)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Book Info")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .padding(.bottom, 10)
                            .padding(.horizontal, 4)

                        glassCard {
                            VStack(spacing: 0) {
                                Text(bookName)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(.label))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)

                                cardDivider

                                Text(bookAuthor)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(.label))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)

                                cardDivider

                                TextField("Total Pages", text: $totalPages)
                                    .font(.system(size: 15))
                                    .keyboardType(.numberPad)
                                    .onChange(of: totalPages) { _, newValue in
                                        totalPages = newValue.filter { $0.isNumber }
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                            }
                        }
                    }

                    // ── Reading Goal ──────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Reading Goal")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .padding(.bottom, 10)
                            .padding(.horizontal, 4)

                        glassCard {
                            VStack(spacing: 16) {

                                // Segmented control
                                HStack(spacing: 0) {
                                    ForEach(["Pages", "Time"], id: \.self) { type in
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                                goalType = type
                                            }
                                        } label: {
                                            Text(type)
                                                .font(.system(size: 14, weight: goalType == type ? .semibold : .regular))
                                                .foregroundStyle(goalType == type ? .white : Color(.secondaryLabel))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 9)
                                                .background(goalType == type ? brown : Color.clear)
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(4)
                                .background(brown.opacity(0.1))
                                .clipShape(Capsule())

                                ZStack {

                                    // Pages stepper
                                    HStack(spacing: 12) {
                                        stepperButton(icon: "minus") {
                                            if dailyPages > 1 {
                                                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                                    dailyPages -= 1
                                                }
                                            }
                                        }

                                        Text("\(dailyPages)")
                                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color(hex: "2C1A0E"))
                                            .frame(width: 100, height: 44)
                                            .background(.ultraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(
                                                        LinearGradient(
                                                            colors: [.white.opacity(0.7), .white.opacity(0.15)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .contentTransition(.numericText())
                                            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: dailyPages)

                                        stepperButton(icon: "plus") {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                                dailyPages += 1
                                            }
                                        }
                                    }
                                    .opacity(goalType == "Pages" ? 1 : 0)
                                    .scaleEffect(goalType == "Pages" ? 1 : 0.97)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: goalType)

                                    // Time pickers
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.5), .white.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                        HStack(spacing: 0) {
                                            Picker("Hours", selection: $hours) {
                                                ForEach(0..<24) { Text("\($0)h").tag($0) }
                                            }
                                            .pickerStyle(.wheel).frame(maxWidth: .infinity)

                                            Picker("Minutes", selection: $minutes) {
                                                ForEach(0..<60) { Text("\($0)m").tag($0) }
                                            }
                                            .pickerStyle(.wheel).frame(maxWidth: .infinity)

                                            Picker("Seconds", selection: $seconds) {
                                                ForEach(0..<60) { Text("\($0)s").tag($0) }
                                            }
                                            .pickerStyle(.wheel).frame(maxWidth: .infinity)
                                        }
                                        .frame(height: 120)
                                    }
                                    .opacity(goalType == "Time" ? 1 : 0)
                                    .scaleEffect(goalType == "Time" ? 1 : 0.97)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: goalType)
                                }
                                .frame(height: 120)
                            }
                            .padding(16)
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.top, 76)
                .padding(.horizontal, 20)
            }

            // ── Top Bar ──────────────────────────────────────────
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1))
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                }
                Spacer()
                Text("Add Book")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Button {
                    save()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(canSave ? Color(.label) : Color(.tertiaryLabel))
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1))
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                }
                .disabled(!canSave)
                .animation(.easeInOut(duration: 0.2), value: canSave)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .task { await loadCover() }
    }

    // MARK: - Reusable Views

    @ViewBuilder
    private func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.65), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            content()
        }
        .shadow(color: .black.opacity(0.06), radius: 14, y: 4)
    }

    @ViewBuilder
    private func stepperButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle().fill(.ultraThinMaterial)
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.8), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(brown)
            }
            .frame(width: 44, height: 44)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(brown.opacity(0.12))
            .frame(height: 1)
            .padding(.horizontal, 18)
    }

    // MARK: - Load Cover

    private func loadCover() async {
        guard let urlString = googleBook.thumbnailURL,
              let url = URL(string: urlString) else {
            isLoadingCover = false
            return
        }
        // Use higher-res cover by replacing zoom param
        let hiResURL = URL(string: urlString.replacingOccurrences(of: "zoom=1", with: "zoom=2")) ?? url
        do {
            let (data, _) = try await URLSession.shared.data(from: hiResURL)
            if let img = UIImage(data: data) {
                await MainActor.run {
                    withAnimation { coverImage = img }
                }
            }
        } catch {}
        await MainActor.run { isLoadingCover = false }
    }

    // MARK: - Save

    private func save() {
        let goalValue: String
        if goalType == "Pages" {
            goalValue = "Pages:\(dailyPages)"
        } else {
            let total = (hours * 3600) + (minutes * 60) + seconds
            goalValue = total > 0 ? "Time:\(total)" : ""
        }

        var imageBase64 = ""
        if let img = coverImage, let data = img.jpegData(compressionQuality: 0.8) {
            imageBase64 = data.base64EncodedString()
        }

        let newBook = Book(
            bookName:   bookName,
            bookImage:  imageBase64,
            bookGoal:   goalValue,
            reflection: "",
            bookRate:   0.0,
            status:     "reading",
            totalPages: Int(totalPages) ?? 0
        )
        newBook.bookAuthor = bookAuthor.isEmpty ? "Unknown Author" : bookAuthor
        modelContext.insert(newBook)

        let descriptor = FetchDescriptor<User>()
        if let existingUser = try? modelContext.fetch(descriptor).first {
            newBook.user = existingUser
            existingUser.books?.append(newBook)
        } else {
            let library = Library(completedBooks: [], wishlistBooks: [])
            let user    = User(userName: "", userIcon: "", streak: 0)
            user.books   = [newBook]
            user.library = library
            newBook.user = user
            library.user = user
            modelContext.insert(user)
            modelContext.insert(library)
        }

        try? modelContext.save()
        onSave()
        dismiss()
    }
}

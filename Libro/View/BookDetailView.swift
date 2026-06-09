//
//  BookDetailView.swift
//  Libro
//
//  Created by wessal hashim alharbi on 04/06/2026.
//
import SwiftUI
import SwiftData

// MARK: - ShareCardView

struct ShareCardView: View {
    let book: Book
    
    private var coverImage: UIImage? {
        guard let name = book.bookImage, !name.isEmpty else { return nil }
        if let img = UIImage(named: name) { return img }
        if let data = Data(base64Encoded: name) { return UIImage(data: data) }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Main Row — Cover + Info
            HStack(alignment: .top, spacing: 16) {
                
                // Cover Image
                Group {
                    if let img = coverImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 105)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("darkbrown").opacity(0.4))
                            .frame(width: 72, height: 105)
                    }
                }
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                
                // Info
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text(book.bookName ?? "")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("darkbrown"))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Stars
                    if let rate = book.bookRate {
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: Float(i) <= rate ? "star.fill" : "star")
                                    .foregroundStyle(Float(i) <= rate ? Color("buttons") : Color.gray.opacity(0.35))
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    
                    // Reflection
                    if let reflection = book.reflection, !reflection.isEmpty {
                        Text(reflection)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.primary.opacity(0.65))
                            .lineSpacing(4)
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            
            Divider()
                .background(Color.gray.opacity(0.2))
                .padding(.horizontal, 20)
            
            // MARK: Footer — Logo + App Name
            HStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Text("Libro")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("darkbrown"))
            }
            .padding(.vertical, 14)
        }
        .frame(width: 320)
        .background(Color("background"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 5)
    }
}

// MARK: - BookDetailView

struct BookDetailView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var renderedImage: UIImage? = nil
    
    private var coverImage: UIImage? {
        guard let name = book.bookImage, !name.isEmpty else { return nil }
        if let img = UIImage(named: name) { return img }
        if let data = Data(base64Encoded: name) { return UIImage(data: data) }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            Group {
                                if let img = coverImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 160, height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("darkbrown").opacity(0.5))
                                        .frame(width: 160, height: 220)
                                }
                            }
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
                            
                            Text(book.bookName ?? "")
                                .font(.title2).fontWeight(.bold).foregroundColor(Color("darkbrown"))
                                .multilineTextAlignment(.center)
                            
                            if let rate = book.bookRate {
                                HStack(spacing: 6) {
                                    ForEach(1...5, id: \.self) { i in
                                        Image(systemName: Float(i) <= rate ? "star.fill" : "star")
                                            .foregroundStyle(Float(i) <= rate ? Color("buttons") : Color.gray.opacity(0.4))
                                            .font(.title3)
                                    }
                                }
                            }
                            
                            HStack(spacing: 0) {
                                VStack(spacing: 4) {
                                    Text(latestSessionDate)
                                        .font(.title3).foregroundColor(Color("darkbrown"))
                                    Text("DATE")
                                        .font(.caption2).foregroundColor(Color("gray"))
                                        .kerning(1.5)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 1, height: 40)
                                
                                VStack(spacing: 4) {
                                    Text(totalDuration)
                                        .font(.title3).foregroundColor(Color("darkbrown"))
                                        .fontWeight(.semibold)
                                    Text("DURATION")
                                        .font(.caption2).foregroundColor(Color("gray"))
                                        .kerning(1.5)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            if let reflection = book.reflection, !reflection.isEmpty {
                                Text(reflection)
                                    .font(.body).lineSpacing(6)
                                    .foregroundStyle(Color.primary.opacity(0.8))
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .glassEffect(.regular.tint(.clear), in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(24)
                    }
                    
                    // MARK: Journey Button — ثابت في الأسفل
                    NavigationLink(destination: JourneyView(book: book)) {
                        Text("Journey")
                            .font(.title3).fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color("buttons"))
                            .clipShape(Capsule())
                            .glassEffect()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .padding(.top, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.medium)
                            .padding(10)
                            .clipShape(Circle())
                    }
                    .tint(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        renderAndShare()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .fontWeight(.medium)
                            .padding(10)
                            .clipShape(Circle())
                    }
                    .tint(.primary)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = renderedImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }
    
    // MARK: - Render Card to Image
    
    @MainActor
    private func renderAndShare() {
        let card = ShareCardView(book: book)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            renderedImage = image
            showShareSheet = true
        }
    }
    
    private var latestSessionDate: String {
        guard let sessions = book.sessions,
              let latest = sessions.compactMap({ $0.date }).max() else { return "—" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: latest).uppercased()
    }
    
    private var totalDuration: String {
        guard let sessions = book.sessions, !sessions.isEmpty else { return "—" }
        let dates = sessions.compactMap { $0.date }
        guard let first = dates.min(), let last = dates.max() else { return "—" }
        let days = Calendar.current.dateComponents([.day], from: first, to: last).day ?? 0
        if days == 0 { return "1d" }
        return "\(days)d"
    }
}

// MARK: - ShareSheet (UIActivityViewController Wrapper)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


#Preview {
    let book = Book(bookName: "Atomic Habits", bookImage: "", bookGoal: "Pages:30",
                    reflection: "This book changed the way I think about habits and daily routines.", bookRate: 4, status: "finished", totalPages: 320)
    BookDetailView(book: book)
        .modelContainer(for: [Book.self, Session.self, User.self], inMemory: true)
}

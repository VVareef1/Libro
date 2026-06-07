import SwiftUI

struct HomeView: View {
    var avatarImage: Image?
    var userName: String

    @State private var selectedTab: Tab = .home

    enum Tab { case home, addBook, library }

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            VStack(spacing: 0) {

                // Top bar
                HStack {
                    Spacer()
// Profile
                    Group {
                        if let avatarImage {
                            avatarImage
                                .resizable()
                                .scaledToFill()
                        } else {
                            Circle()
                                .fill(Color(.systemGray3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Group {
                    switch selectedTab {
                    case .home:    homeContent
                    case .addBook: addBookContent
                    case .library: libraryContent
                    }
                }

                Spacer()

                // Bottom nav
                HStack(spacing: 0) {
                    TabBarItem(icon: "house", label: "Home", isActive: selectedTab == .home) { selectedTab = .home }
                    TabBarItem(icon: "plus", label: "Add book", isActive: selectedTab == .addBook) { selectedTab = .addBook }
                    TabBarItem(icon: "chart.bar", label: "Library", isActive: selectedTab == .library) { selectedTab = .library }
                }
                .padding(.horizontal, 8)
                .padding(.top, 10)
                .padding(.bottom, 30)
                .background(Color("background"))
                .overlay(Rectangle().fill(Color(.systemGray5)).frame(height: 0.5), alignment: .top)
            }
        }
        .navigationBarHidden(true)
    }

    var homeContent: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "book.closed.fill")
                .font(.system(size: 72))
                .foregroundColor(Color("buttons"))

            Spacer().frame(height: 8)

            Text("Start your reading Journey!")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(Color("darkbrown"))
                .multilineTextAlignment(.center)

            Text("Add some books so you\ncan get started")
                .font(.system(size: 13))
                .foregroundColor(Color("darkbrown").opacity(0.45))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: 8)

            Button { selectedTab = .addBook } label: {
                Text("Add")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 52)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(Color("buttons")))
            }
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    var addBookContent: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("buttons"))
            Text("Add a Book")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color("darkbrown"))
            Text("Search for a book to add\nto your library")
                .font(.system(size: 13))
                .foregroundColor(Color("darkbrown").opacity(0.45))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    var libraryContent: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("darkbrown"))
            Text("Your Library")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color("darkbrown"))
            Text("Your added books\nwill appear here")
                .font(.system(size: 13))
                .foregroundColor(Color("darkbrown").opacity(0.45))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon + (isActive ? ".fill" : ""))
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? Color("darkbrown") : Color(.systemGray3))
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(isActive ? Color("darkbrown") : Color(.systemGray3))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(isActive ? Color(.systemGray6) : Color.clear)
                    .padding(.horizontal, 4)
            )
        }
    }
}

#Preview { HomeView(avatarImage: nil, userName: "Sally") }

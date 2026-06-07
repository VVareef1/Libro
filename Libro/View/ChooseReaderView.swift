//
//  ChooseReaderView.swift
//  Libro
//

import SwiftUI
import SwiftData

struct ChooseReaderView: View {

    var onContinue: () -> Void

    @State private var name           = ""
    @State private var selectedAvatar = 3

    @Environment(\.modelContext) private var modelContext

    private let avatarOrder = [1, 2, 3, 4]

    var body: some View {
        VStack(spacing: 0) {

            Spacer().frame(height: 36)

            Text("Choose a Reader")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color("darkbrown"))

            Spacer().frame(height: 52)

            // ── Swipeable Avatar Carousel ─────────────────────────
            AvatarCarousel(
                avatarOrder:    avatarOrder,
                selectedAvatar: $selectedAvatar
            )
            .frame(height: 340)

            Spacer().frame(height: 8)

            // ── Name field ────────────────────────────────────────
            VStack(spacing: 0) {
                TextField("Give a name", text: $name)
                    .font(.system(size: 20))
                    .foregroundColor(name.isEmpty ? Color("gray") : Color("darkbrown"))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .textInputAutocapitalization(.words)

                Rectangle()
                    .fill(Color("darkbrown").opacity(0.18))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
            }
            .onTapGesture { }
            Spacer()

            // ── Continue button ───────────────────────────────────
            Button {
                saveUser()
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(name.isEmpty ? Color("darkbrown").opacity(0.35) : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        Capsule()
                            .fill(name.isEmpty
                                  ? Color("darkbrown").opacity(0.08)
                                  : Color("buttons"))
                    )
                    .animation(.easeInOut(duration: 0.2), value: name.isEmpty)
            }
            .disabled(name.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Save User
    private func saveUser() {
        let iconName = "avatar\(selectedAvatar)"
        let descriptor = FetchDescriptor<User>()
        if let existingUser = try? modelContext.fetch(descriptor).first {
            existingUser.userName = name
            existingUser.userIcon = iconName
        } else {
            let user    = User(userName: name, userIcon: iconName, streak: 0)
            let library = Library(completedBooks: [], wishlistBooks: [])
            user.library = library
            library.user = user
            modelContext.insert(user)
            modelContext.insert(library)
        }
        try? modelContext.save()
    }
}

// MARK: - Avatar Carousel (ScrollView + snap)

struct AvatarCarousel: View {

    let avatarOrder:    [Int]
    @Binding var selectedAvatar: Int

    private let circleCenter: CGFloat = 180
    private let circleSide:   CGFloat = 130
    private let imageCenter:  CGFloat = 321
    private let imageSide:    CGFloat = 248
    private let spacing:      CGFloat = 20

    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {

                        let leadingPad = leadingPadding(geo: geo)
                        Color.clear.frame(width: leadingPad)

                        ForEach(avatarOrder, id: \.self) { avatarNum in
                            let isCenter = avatarNum == selectedAvatar

                            Circle()
                                .fill(Color(hex: "EDE8E3"))
                                .frame(
                                    width:  isCenter ? circleCenter : circleSide,
                                    height: isCenter ? circleCenter : circleSide
                                )
                                .overlay(
                                    Image("avatar\(avatarNum)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(
                                            width:  isCenter ? imageCenter : imageSide,
                                            height: isCenter ? imageCenter : imageSide
                                        )
                                )
                                .opacity(isCenter ? 1.0 : 0.5)
                                .scaleEffect(isCenter ? 1.0 : 0.85)
                                .id(avatarNum)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                                        selectedAvatar = avatarNum
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                                            proxy.scrollTo(avatarNum, anchor: .center)
                                        }
                                    }
                                }
                                .animation(.spring(response: 0.38, dampingFraction: 0.78), value: selectedAvatar)
                        }

                        // ── trailing padding ──
                        Color.clear.frame(width: leadingPadding(geo: geo))
                    }
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollDismissesKeyboard(.immediately)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        proxy.scrollTo(selectedAvatar, anchor: .center)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 40
                            let currentIndex = avatarOrder.firstIndex(of: selectedAvatar) ?? 0
                            var newIndex = currentIndex

                            if value.translation.width < -threshold {
                                newIndex = min(currentIndex + 1, avatarOrder.count - 1)
                            } else if value.translation.width > threshold {
                                newIndex = max(currentIndex - 1, 0)
                            }

                            if newIndex != currentIndex {
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                                    selectedAvatar = avatarOrder[newIndex]
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                                        proxy.scrollTo(avatarOrder[newIndex], anchor: .center)
                                    }
                                }
                            }
                        }
                )
            }
        }
    }

    private func leadingPadding(geo: GeometryProxy) -> CGFloat {
        (geo.size.width - circleCenter) / 2
    }
}

#Preview {
    ChooseReaderView { }
}

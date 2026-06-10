//
//  CelebretionView.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 03/06/2026.
//

import SwiftUI
import SwiftData

struct CongratulationView: View {

    let book: Book

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CongratulationViewModel()
    @State private var navigateToReflection = false
    @State private var navigateToHome = false

    @Query private var users: [User]
    private var userIconName: String {
        users.first?.userIcon ?? "avatar3"
    }

    private let accentBrown = Color(red: 0.56, green: 0.42, blue: 0.28)

    var body: some View {
        NavigationStack {
            ZStack {
                Color("background")
                    .ignoresSafeArea()

                ConfettiLayer(pieces: viewModel.pieces, animating: viewModel.animating)

                VStack(spacing: 0) {

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 161, height: 161)
                            .glassEffect(.regular.tint(Color(hex: "EDE8E3")), in: .circle)

                        Image(userIconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                    }

                    Text("Congratulations!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(UIColor.label))
                        .padding(.top, 20)

                    Spacer()

                    VStack(spacing: 16) {
                        Button(action: { navigateToReflection = true }) {
                            Text("Reflect")
                                .font(.title3).fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .glassEffect(.regular.tint(Color("buttons")), in: .capsule)
                        }

                        Button(action: { navigateToHome = true }) {
                            Text("Skip")
                                .font(.title3).fontWeight(.semibold)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 44)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToReflection) {
                ReflectionView(book: book)
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                viewModel.startAnimation()
            }
        }
    }
}


struct ConfettiLayer: View {

    let pieces: [ConfettiPiece]
    let animating: Bool

    var body: some View {
        GeometryReader { geo in
            ForEach(pieces) { piece in
                ConfettiPieceView(piece: piece, animating: animating, containerSize: geo.size)
            }
        }
        .ignoresSafeArea()
    }
}


struct ConfettiPieceView: View {

    let piece: ConfettiPiece
    let animating: Bool
    let containerSize: CGSize

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var spin: Double = 0

    var body: some View {
        pieceShape
            .frame(width: pieceWidth, height: pieceHeight)
            .rotationEffect(.degrees(piece.rotation + spin))
            .scaleEffect(piece.scale)
            .opacity(opacity)
            .position(
                x: piece.x * containerSize.width,
                y: piece.y * containerSize.height + offsetY
            )
            .onAppear {
                guard animating else { return }
                let duration = Double.random(in: 2.5...4.5)
                let delay = Double.random(in: 0...0.5)

                withAnimation(
                    Animation.easeIn(duration: duration).delay(delay)
                ) {
                    offsetY = containerSize.height * 1.1
                    opacity = Double.random(in: 0.4...1.0)
                    spin = Double.random(in: 180...540)
                }
            }
    }

    private var pieceWidth: CGFloat {
        piece.shape == .square ? 12 * piece.scale : 8 * piece.scale
    }

    private var pieceHeight: CGFloat {
        piece.shape == .square ? 12 * piece.scale : 16 * piece.scale
    }

    @ViewBuilder
    private var pieceShape: some View {
        let c = piece.color.value
        let color = Color(red: c.r, green: c.g, blue: c.b)
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
    }
}


#Preview {
    let book = Book(bookName: "Atomic Habits", bookImage: "", bookGoal: "Pages:30",
                    reflection: "", bookRate: 0, status: "reading", totalPages: 320)
    CongratulationView(book: book)
        .modelContainer(for: [User.self, Book.self], inMemory: true)
}

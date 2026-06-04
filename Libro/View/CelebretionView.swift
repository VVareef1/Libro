//
//  CelebretionView.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 03/06/2026.
//

import SwiftUI


struct CongratulationView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CongratulationViewModel()

    private let accentBrown = Color(red: 0.56, green: 0.42, blue: 0.28)

    var body: some View {
        ZStack {

            Color("background")
                .ignoresSafeArea()

            ConfettiLayer(pieces: viewModel.pieces, animating: viewModel.animating)

            VStack(spacing: 0) {

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 161, height: 161)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                        .glassEffect()

                    Image("uIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 115, height: 115)
//                        .foregroundColor(Color(red: 0.75, green: 0.55, blue: 0.40))
                }

                Text("Congratulation")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
                    .padding(.top, 20)

                Spacer()

                Button(action: { viewModel.tapDone() }) {
                    Text("All Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(accentBrown)
                        .cornerRadius(27)
                }
                .padding(.horizontal, 44)
                .padding(.bottom, 44)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startAnimation()
        }
        .onChange(of: viewModel.didTapDone) { _, done in
            if done { dismiss() }
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
                let delay = Double.random(in: 0...1.5)

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
    CongratulationView()
}

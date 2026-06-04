//
//  CelebretionViewModel.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 03/06/2026.
//

import SwiftUI
import Combine


@MainActor
final class CongratulationViewModel: ObservableObject {

    @Published var pieces: [ConfettiPiece] = []
    @Published var animating: Bool = false
    @Published var didTapDone: Bool = false

    private var fallTimers: [AnyCancellable] = []
    private let pieceCount = 60

    init() {
        spawnConfetti()
    }

    func startAnimation() {
        animating = true
        scheduleFallLoop()
    }

    func tapDone() {
        didTapDone = true
    }

    private func spawnConfetti() {
        pieces = (0..<pieceCount).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: -0.3...0.6),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2),
                color: ConfettiPiece.ConfettiColor.allCases.randomElement()!,
                shape: ConfettiPiece.ConfettiShape.allCases.randomElement()!
            )
        }
    }

    private func scheduleFallLoop() {
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnConfetti()
            }
            .store(in: &fallTimers)
    }
}

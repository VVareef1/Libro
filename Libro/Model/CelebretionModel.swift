//
//  CelebretionModel.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 03/06/2026.
//

import Foundation


struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var scale: CGFloat
    var color: ConfettiColor
    var shape: ConfettiShape

    enum ConfettiColor: CaseIterable {
        case pink, purple, darkPink, darkPurple

        var value: (r: Double, g: Double, b: Double) {
            switch self {
            case .pink:       return (0.94, 0.55, 0.70)
            case .purple:     return (0.60, 0.40, 0.85)
            case .darkPink:   return (0.82, 0.20, 0.45)
            case .darkPurple: return (0.45, 0.20, 0.75)
            }
        }
    }

    enum ConfettiShape: CaseIterable {
        case square, rectangle
    }
}

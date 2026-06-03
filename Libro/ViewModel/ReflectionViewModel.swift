//
//  ReflectionViewModel.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 03/06/2026.
//

import SwiftUI
import Combine


@MainActor
final class ReflectionViewModel: ObservableObject {

    @Published var rating: Int = 0
    @Published var reflection: String = ""
    @Published var didSubmit: Bool = false
    @Published var didSkip: Bool = false

    var isReflectionEmpty: Bool {
        reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canSubmit: Bool {
        rating > 0
    }

    func selectRating(_ star: Int) {
        withAnimation(.easeInOut(duration: 0.15)) {
            rating = star
        }
    }

    func submitJourney() {
        guard canSubmit else { return }
        didSubmit = true
    }

    func skip() {
        didSkip = true
    }
}

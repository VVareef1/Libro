//
//  ReflectionViewModel.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 03/06/2026.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class ReflectionViewModel: ObservableObject {

    @Published var rating: Int = 0
    @Published var reflection: String = ""
    @Published var didSubmit: Bool = false
    @Published var didSkip: Bool = false

    private var book: Book?
    private var modelContext: ModelContext?

    init(book: Book? = nil, modelContext: ModelContext? = nil) {
        self.book = book
        self.modelContext = modelContext
    }

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

        if let book, let modelContext {
            book.bookRate = Float(rating)
            book.reflection = reflection.trimmingCharacters(in: .whitespacesAndNewlines)
            try? modelContext.save()
        }

        didSubmit = true
    }

    func skip() {
        didSkip = true
    }
    
    func updateContext(_ context: ModelContext) {
        self.modelContext = context
    }

}

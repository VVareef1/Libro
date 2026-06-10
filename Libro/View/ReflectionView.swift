//
//  ReflectionView.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 03/06/2026.
//

import SwiftUI
import SwiftData

struct ReflectionView: View {

    let book: Book?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ReflectionViewModel

    private let accentBrown = Color(red: 0.56, green: 0.42, blue: 0.28)

    init(book: Book? = nil) {
        self.book = book
        _viewModel = StateObject(wrappedValue: ReflectionViewModel(book: book))
    }

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                        .frame(width: 44, height: 44)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }
                .padding(.top, 16)
                .padding(.leading, 20)

                Text("Take along a book")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color("darkbrown"))
                    .padding(.top, 12)
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Rate your Experience")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color("darkbrown"))

                    StarRatingView(
                        rating: viewModel.rating,
                        accentColor: accentBrown,
                        onSelect: { star in
                            viewModel.selectRating(star)
                        }
                    )
                }
                .padding(.top, 40)
                .padding(.horizontal, 20)

                ReflectionEditorView(text: $viewModel.reflection)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                Spacer()

                Button(action: { viewModel.submitJourney() }) {
                    Text("Journey")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(accentBrown)
                        .cornerRadius(27)
                        .glassEffect()
                }
                .padding(.horizontal, 44)
                .padding(.bottom, 36)
            }
            .background(Color("background").ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                viewModel.updateContext(modelContext)
            }
            .onChange(of: viewModel.didSubmit) { _, submitted in
                if submitted { dismiss() }
            }
            .onChange(of: viewModel.didSkip) { _, skipped in
                if skipped { dismiss() }
            }
        }
    }
}

struct StarRatingView: View {

    let rating: Int
    let accentColor: Color
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(
                        star <= rating ? accentColor : Color(UIColor.systemGray3)
                    )
                    .onTapGesture { onSelect(star) }
            }
        }
    }
}

struct ReflectionEditorView: View {

    @Binding var text: String

    private let fieldBackground = Color(red: 0.92, green: 0.89, blue: 0.84)

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("Write a reflection")
                    .font(.system(size: 16))
                    .foregroundColor(Color(UIColor.placeholderText))
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(.system(size: 16))
                .foregroundColor(Color(UIColor.label))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
        }
        .frame(height: 260)
        .glassEffect(.regular.tint(fieldBackground.opacity(0.5)), in: .rect(cornerRadius: 16))
    }
}

#Preview {
    ReflectionView(book: nil)
}

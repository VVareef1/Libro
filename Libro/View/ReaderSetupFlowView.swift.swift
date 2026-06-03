//
//  ReaderSetupFlowView.swift
//  Libro
//
//  Created by Rana on 11/12/1447 AH.
//

import Foundation
import SwiftUI

struct ReaderSetupFlowView: View {

    @State private var currentStep = 1
    @State private var selectedCategories: [String] = []
    @State private var selectedBook: GoogleBook?

    private let totalSteps = 3

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                ProgressHeaderView(
                    currentStep: $currentStep,
                    totalSteps: totalSteps
                ) {
                    currentStep = totalSteps + 1
                }

                switch currentStep {

                case 1:
                    CategoryView { categories in
                        selectedCategories = categories
                        currentStep += 1
                    }

                case 2:
                    RecommendationView(
                        selectedCategories: selectedCategories
                    ) { book in
                        selectedBook = book
                    }

                default:
                    EmptyView()
                }
            }
        }
        .fullScreenCover(item: $selectedBook) { book in
            ReadingSetupFlowView(
                bookPages: book.pageCount
            )
        }
    }
}

#Preview {
    ReaderSetupFlowView()
}

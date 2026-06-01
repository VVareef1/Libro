//
//  ReaderSetupFlowView.swift.swift
//  Libro
//
//  Created by Rana on 11/12/1447 AH.
//

import Foundation
import SwiftUI

struct ReaderSetupFlowView: View {

    @State private var currentStep = 1

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
                    CategoryView {
                        currentStep += 1
                    }

                case 2:
                    RecommendationView {
                        currentStep += 1
                    }

                case 3:
                    PlaceholderView(
                        title: "Books Picked For You"
                    ) {
                        currentStep += 1
                    }

                default:
                    EmptyView()
                }
            }
        }
    }
}

struct PlaceholderView: View {

    let title: String
    let onContinue: () -> Void

    var body: some View {
        VStack {

            Spacer()

            Text(title)
                .font(.title2.bold())

            Spacer()

            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 292, height: 58)
                    .background(Color("buttons"))
                    .clipShape(Capsule())
            }
            .padding(.bottom, 54)
        }
    }
}

#Preview {
    ReaderSetupFlowView()
}

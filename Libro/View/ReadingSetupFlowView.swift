//
//  ReadingSetupFlowView.swift
//  Libro
//
//  Created by Rana on 11/12/1447 AH.
//

import Foundation
import SwiftUI

struct ReadingSetupFlowView: View {
    
    @State private var currentStep = 1
    
    @State private var bookPages = 500
    @State private var selectedGoal: String? = nil
    @State private var dailyPages = 0
    @State private var hours = 0
    @State private var minutes = 15
    @State private var seconds = 0
    
    private let totalSteps = 4
    
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
                    BookPagesView(
                        bookPages: bookPages
                    ) { pages in
                        bookPages = pages
                        currentStep += 1
                    }
                    
                case 2:
                    GoalView(
                        selectedGoal: $selectedGoal
                    ) {
                        currentStep += 1
                    }
                    
                case 3:
                    if selectedGoal == "Pages" {
                        DailyPagesView(
                            dailyPages: dailyPages
                        ) { pages in
                            dailyPages = pages
                            currentStep += 1
                        }
                    } else {
                        DailyTimeView { h, m, s in
                            hours = h
                            minutes = m
                            seconds = s
                            currentStep += 1
                        }
                    }
                    
                default:
                    EmptyView()
                }
            }
        }
    }
}
#Preview {
    ReadingSetupFlowView()
}

//
//  GoalView.swift
//  Libro
//
//  Created by Rana on 07/12/1447 AH.
//

import SwiftUI

struct GoalView: View {
    
    @Binding var selectedGoal: String?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text("What’s your preferred\nreading goal?")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color("darkbrown"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 150)
            
            VStack(spacing: 22) {
                goalButton("Pages")
                goalButton("Time")
            }
            .padding(.top, 90)
            
            Spacer()
            
            continueButton
                .padding(.bottom, 34)
        }
    }
    
    private func goalButton(_ title: String) -> some View {
        Button {
            selectedGoal = title
        } label: {
            Text(title)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(selectedGoal == title ? .white : Color("darkbrown"))
                .frame(width: 280, height: 54)
                .background(selectedGoal == title ? Color("buttons") : Color.clear)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color("buttons"), lineWidth: 1)
                }
        }
    }
    
    private var continueButton: some View {
        Button {
            onContinue()
        } label: {
            Text("Continue")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(selectedGoal == nil ? Color("gray") : .white)
                .frame(width: 320, height: 58)
                .background(selectedGoal == nil ? Color("lightGray") : Color("buttons"))
                .clipShape(Capsule())
        }
        .disabled(selectedGoal == nil)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GoalView(selectedGoal: .constant(nil)) {
        
    }
}

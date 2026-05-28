//
//  ProgressHeaderView.swift
//  Libro
//
//  Created by Rana on 11/12/1447 AH.
//

import Foundation
import SwiftUI

struct ProgressHeaderView: View {
    
    @Binding var currentStep: Int
    let totalSteps: Int
    let onSkip: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .center, spacing: 12) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("lightGray"))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(Color("buttons"))
                        .frame(
                            width: UIScreen.main.bounds.width * 0.6 *
                            (CGFloat(currentStep) / CGFloat(totalSteps)),
                            height: 10
                        )
                        .animation(.spring(response: 0.4), value: currentStep)
                }
                
                Button("Skip") {
                    onSkip()
                }
                .font(.system(size: 15))
                .foregroundColor(Color("gray"))
                .fixedSize()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Text("\(currentStep)/\(totalSteps)")
                .font(.system(size: 12))
                .foregroundColor(Color("gray"))
                .padding(.leading, 24)
                .padding(.top, 4)
        }
    }
}

#Preview {
    ProgressHeaderView(
        currentStep: .constant(1),
        totalSteps: 3
    ) {
        
    }
}

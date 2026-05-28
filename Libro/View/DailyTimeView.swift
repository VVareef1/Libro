//
//  DailyTimeView.swift
//  Libro
//
//  Created by Rana on 07/12/1447 AH.
//

import SwiftUI

struct DailyTimeView: View {
    
    @State private var hours = 0
    @State private var minutes = 15
    @State private var seconds = 0
    
    let onContinue: (Int, Int, Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            title
                .padding(.top, 66)
            
            timePicker
                .padding(.top, 90)
            
            Spacer()
            
            continueButton
                .padding(.bottom, 54)
        }
    }
}

extension DailyTimeView {
    
    private var title: some View {
        Text("How much time do you\nwant to read daily?")
            .font(.system(size: 26, weight: .bold))
            .foregroundColor(Color("darkbrown"))
            .multilineTextAlignment(.center)
    }
}

extension DailyTimeView {
    
    private var timePicker: some View {
        HStack(spacing: 0) {
            
            wheel(
                value: $hours,
                range: 0...23,
                unit: "hours"
            )
            
            wheel(
                value: $minutes,
                range: 0...59,
                unit: "min"
            )
            
            wheel(
                value: $seconds,
                range: 0...59,
                unit: "sec"
            )
        }
        .frame(height: 180)
    }
    
    private func wheel(
        value: Binding<Int>,
        range: ClosedRange<Int>,
        unit: String
    ) -> some View {
        Picker("", selection: value) {
            ForEach(range, id: \.self) { number in
                Text("\(number) \(unit)")
                    .font(.system(size: 24))
                    .tag(number)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 115)
        .clipped()
    }
}

extension DailyTimeView {
    
    private var continueButton: some View {
        Button {
            onContinue(hours, minutes, seconds)
        } label: {
            Text("Continue")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 292, height: 58)
                .background(Color("buttons"))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    DailyTimeView { _, _, _ in
        
    }
}

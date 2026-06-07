//
//  Untitled.swift
//  Libro
//
//  Created by Wareef Saeed Alzahrani on 05/06/2026.
//
import SwiftUI

struct SplashView: View {
    @State private var progress: CGFloat = 0
    @State private var isActive = false

    var body: some View {
        if isActive {
            ChooseReaderView()
        } else {
            ZStack {
                Color("background").ignoresSafeArea()

                VStack(spacing: 12) {
                    Text("Libro")
                        .font(.custom("DMSerifDisplay-Regular", size: 64))
                        .foregroundColor(Color("darkbrown"))

                    Text("YOUR READING JOURNEY")
                        .font(.custom("DMSans-Regular", size: 11))
                        .tracking(2)
                        .foregroundColor(Color("darkbrown").opacity(0.5))

                    Spacer().frame(height: 48)

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color("darkbrown").opacity(0.2))
                            .frame(width: 56, height: 3)
                        Capsule()
                            .fill(Color("darkbrown"))
                            .frame(width: 56 * progress, height: 3)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0)) {
                    progress = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}


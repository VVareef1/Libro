//
//  CustomAlertView.swift
//  Libro
//

import SwiftUI


struct CustomAlertView<Content: View>: View {
    let title: String
    let confirmLabel: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @ViewBuilder let content: () -> Content

    private let brown = Color("darkbrown")
    private let background = Color(red: 0.93, green: 0.90, blue: 0.85)

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { } // block taps through

            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(brown)
                    .multilineTextAlignment(.center)

                content()

                HStack(spacing: 12) {
                    // Confirm — brown filled
                    Button(action: onConfirm) {
                        Text(confirmLabel)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(brown)
                            .clipShape(Capsule())
                    }

                    // Cancel — light filled
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.body.weight(.semibold))
                            .foregroundColor(brown)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(24)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
            .padding(.horizontal, 36)
        }
    }
}

// MARK: - Preview
#Preview {
    CustomAlertView(
        title: "End the session?",
        confirmLabel: "Leave",
        onConfirm: {},
        onCancel: {}
    ) {
        EmptyView()
    }
}

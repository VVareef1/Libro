//
//  SesstionView.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 04/06/2026.
//

import SwiftUI

struct CandleTimerView: View {
    @StateObject private var viewModel = CandleTimerViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showEndConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.95, blue: 0.91).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    Text(viewModel.formattedTime)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.42, green: 0.30, blue: 0.20))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.default, value: viewModel.formattedTime)

                    Spacer()

                    Image("Candle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 500)

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: { viewModel.togglePlayPause() }) {
                            Image(systemName: viewModel.isRunning ? "pause" : "play.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 52)
                                .background(Color(red: 0.42, green: 0.30, blue: 0.20))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        NavigationLink(destination: ReflectionView()) {
                            Image(systemName: "pencil.and.scribble")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 52)
                                .background(Color(red: 0.42, green: 0.30, blue: 0.20))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showEndConfirmation = true }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.42, green: 0.30, blue: 0.20))
                    }
                }
            }
            .toolbarBackground(Color(red: 0.97, green: 0.95, blue: 0.91), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { viewModel.onAppear() }
            .alert("End Session?", isPresented: $showEndConfirmation) {
                Button("End Session", role: .destructive) {
                    viewModel.stop()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to end this session?")
            }
        }
    }
}

#Preview {
    CandleTimerView()
}

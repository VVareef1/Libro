//
//  QoutsSheetView.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 05/06/2026.
//

import SwiftUI

struct NoteSheetView: View {
    @ObservedObject var viewModel: CandleTimerViewModel
    @State private var text: String = ""
    @State private var page: Int = 1
    @State private var pageText: String = "1"

    private let brown = Color("darkbrown")
    private let background = Color(red: 0.97, green: 0.95, blue: 0.91)
    private let fieldBackground = Color(red: 0.92, green: 0.89, blue: 0.84)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack {
                Button(action: { viewModel.showNoteSheet = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(brown)
                        .frame(width: 36, height: 36)
                        .background(fieldBackground)
                        .clipShape(Circle())
                }

                Spacer()

                Button(action: { viewModel.addNote(text: text, page: page) }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(brown)
                        .frame(width: 36, height: 36)
                        .background(fieldBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 8)

            Text("Write a quote or Insight")
                .font(.headline)
                .foregroundColor(brown)
                .frame(maxWidth: .infinity, alignment: .center)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("quote or Insight")
                        .foregroundColor(brown.opacity(0.4))
                        .font(.body)
                        .padding(.top, 10)
                        .padding(.leading, 4)
                }
                TextEditor(text: $text)
                    .font(.body)
                    .foregroundColor(brown)
                    .frame(height: 120)
                    .scrollContentBackground(.hidden)

                VStack {
                    Spacer()
                        HStack {
                            ZStack{
                            Circle()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color(""))
                                .glassEffect()
                            Spacer()
                            Button(action: { /* handle camera */ }) {
                                Image(systemName: "camera")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(brown.opacity(0.6))
                                
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            HStack {
                Text("Page Number:")
                    .font(.callout.weight(.semibold))
                    .foregroundColor(brown)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: {
                        if page > 1 {
                            page -= 1
                            pageText = "\(page)"
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(brown)
                    }

                    TextField("1", text: $pageText)
                        .keyboardType(.numberPad)
                        .font(.body.weight(.semibold))
                        .foregroundColor(brown)
                        .multilineTextAlignment(.center)
                        .frame(width: 52)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(fieldBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onChange(of: pageText) { _, newValue in
                            if let val = Int(newValue), val > 0 {
                                page = val
                            }
                        }

                    Button(action: {
                        page += 1
                        pageText = "\(page)"
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(brown)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(background.ignoresSafeArea())
    }
}

#Preview {
    NoteSheetView(viewModel: CandleTimerViewModel())
        .presentationDetents([.height(380)])
}

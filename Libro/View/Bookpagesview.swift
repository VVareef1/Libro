//
//  Bookpagesview.swift
//  Libro
//
//  Created by Rana on 07/12/1447 AH.
//

import SwiftUI

struct BookPagesView: View {
    
    @State private var pageText: String
    
    let onContinue: (Int) -> Void
    
    init(
        bookPages: Int,
        onContinue: @escaping (Int) -> Void
    ) {
        self._pageText = State(initialValue: "\(bookPages)")
        self.onContinue = onContinue
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            title
                .padding(.top, 66)
            
            counter
                .padding(.top, 150)
            
            Spacer()
            
            continueButton
                .padding(.bottom, 54)
        }
    }
}

extension BookPagesView {
    
    private var title: some View {
        Text("Confirm book pages")
            .font(.system(size: 26, weight: .bold))
            .foregroundColor(Color("darkbrown"))
            .multilineTextAlignment(.center)
    }
}

extension BookPagesView {
    
    private var counter: some View {
        HStack(spacing: 34) {
            
            circleButton("minus") {
                updatePages(by: -1)
            }
            
            TextField("", text: $pageText)
                .keyboardType(.numberPad)
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(Color("darkbrown"))
                .multilineTextAlignment(.center)
                .frame(width: 120, height: 76)
                .background(Color("lightGray"))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .onChange(of: pageText) { newValue in
                    pageText = newValue.filter { $0.isNumber }
                }
            
            circleButton("plus") {
                updatePages(by: 1)
            }
        }
    }
    
    private func circleButton(
        _ icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color("buttons"))
                .clipShape(Circle())
        }
    }
}

extension BookPagesView {
    
    private var continueButton: some View {
        Button {
            onContinue(pageCount)
        } label: {
            Text("Continue")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 292, height: 58)
                .background(Color("buttons"))
                .clipShape(Capsule())
        }
        .disabled(pageCount == 0)
        .opacity(pageCount == 0 ? 0.6 : 1)
    }
}

extension BookPagesView {
    
    private var pageCount: Int {
        Int(pageText) ?? 0
    }
    
    private func updatePages(by value: Int) {
        let newValue = max(1, pageCount + value)
        pageText = "\(newValue)"
    }
}

#Preview {
    BookPagesView(bookPages: 500) { pages in
        
    }
}

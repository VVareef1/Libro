//
//  sesstionInfo.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 14/05/2026.
//

import SwiftUI

public struct sessionInfoView: View {
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Book Name")
                .font(.system(size: 34, weight: .bold, design: .default))
            Image(systemName: "calendar.fill")
                .font(.system(size: 30, weight: .bold, design: .default))
            
            
            
                
        }
    }
}

#Preview{
    sessionInfoView()
}





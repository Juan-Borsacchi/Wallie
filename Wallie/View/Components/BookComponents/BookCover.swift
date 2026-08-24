//
//  BookCover.swift
//  Wallie
//
//  Created by Felipe Colares Cardoso on 22/08/26.
//

import SwiftUI

struct BookCover: View {
    
    @State private var gradientRotation: Double = 0
    
    var body: some View {
         GeometryReader { geometry in
            
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 20
                )
                .fill(.verdeEscuro)
                .frame(width: 200, height: 280)
                .offset(x: -10, y: -10)

            }
            
        }
    }
}

#Preview {
    BookCover()
        .frame(width: 210, height: 280)
        .padding()
}

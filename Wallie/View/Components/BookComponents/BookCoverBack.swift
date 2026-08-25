//  BookCoverBack.swift
//  Wallie
//
//  Created by Felipe Colares Cardoso on 22/08/26.
//

import SwiftUI

struct BookCoverBack: View {

    @State private var gradientRotation: Double = 0

    var body: some View {
        GeometryReader { geometry in

            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 20,
                topTrailingRadius: 20
            )
            .fill(.verdeEscuro)
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }
    }

}

#Preview {
    BookCoverBack()
        .frame(width: 220, height: 290)
        .padding()
}

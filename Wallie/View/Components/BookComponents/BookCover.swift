//  BookCover.swift
//  Wallie
//
//  Created by Felipe Colares Cardoso on 22/08/26.
//

import SwiftUI

struct BookCover: View {

    var side: BookPageSide = .right

    @State private var gradientRotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: stripeAlignment) {
                Rectangle()
                    .fill(.verdeEscuro)

                Rectangle()
                    .fill(.verdeProjeto)
                    .frame(width: 35)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private var stripeAlignment: Alignment {
        side == .right ? .leading : .trailing
    }
}

#Preview {
    HStack(spacing: 20) {
        BookCover(side: .right)
            .frame(width: 210, height: 280)
        BookCover(side: .left)
            .frame(width: 210, height: 280)
    }
    .padding()
}

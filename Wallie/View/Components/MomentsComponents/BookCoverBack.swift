//
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

            ZStack {

                // MARK: Fundo da capa

                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(.gray)


                // MARK: Strokes externos animados

                ForEach(0..<5, id: \.self) { index in

                    RoundedRectangle(
                        cornerRadius: 20 - CGFloat(index * 2),
                        style: .continuous
                    )
                    .stroke(

                        AngularGradient(
                            colors: [
                                .gray,
                                .white,
                                .gray,
                                .white,
                                .gray,
                                .gray
                            ],
                            center: .center,
                            startAngle: .degrees(gradientRotation),
                            endAngle: .degrees(gradientRotation + 360)
                        ),

                        lineWidth: 1.5
                    )
                    .padding(CGFloat(index * 7))
                }


                // MARK: Retângulo central

                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(

                    LinearGradient(
                        colors: [
                            Color.gray,
                            Color.gray,
                            Color.gray,
                            Color.gray,
                            Color.gray,
                            Color.gray,
                            Color.gray,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                )
                .frame(
                    width: geometry.size.width * 0.72,
                    height: geometry.size.height * 0.78
                )


                // MARK: Logo

                Image("OnlyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 100,
                        height: 100
                    )
                    .opacity(0.5)
            }
            .clipShape(

                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
        }
        .onAppear {

            gradientRotation = 0

            withAnimation(
                .linear(duration: 6)
                .repeatForever(autoreverses: false)
            ) {

                gradientRotation = 360
            }
        }
    }
}


#Preview {

    BookCoverBack()
        .frame(width: 210, height: 280)
        .padding()
}

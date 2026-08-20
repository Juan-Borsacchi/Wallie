//
//  MomentCardFace.swift
//  Wallie
//

import SwiftUI

struct MomentCardFace: View {

    let experience: Experience


    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // MARK: Background

                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(
                    Color(.systemGray5)
                )


                // MARK: Placeholder

                if experience.isPlaceholder {

                    Rectangle()
                        .fill(
                            .ultraThinMaterial
                        )


                // MARK: Image

                } else if
                    let data =
                        experience.images.first,
                    let uiImage =
                        UIImage(data: data)
                {

                    Image(
                        uiImage: uiImage
                    )
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()


                // MARK: Empty Image

                } else {

                    Image(
                        systemName:
                            "photo"
                    )
                    .font(
                        .largeTitle
                    )
                    .foregroundStyle(
                        .secondary
                    )

                }

            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipShape(

                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )

            )
            .overlay(

                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .strokeBorder(
                    .white.opacity(0.25),
                    lineWidth: 1
                )

            )

        }

    }


    // MARK: - Rating Badge

    private func ratingBadge(
        _ quality: QualityRating
    ) -> some View {

        HStack(
            spacing: 5
        ) {

            Text(
                quality.imageName
            )

            Text(
                quality.label
            )
            .lineLimit(1)

        }
        .font(
            .caption2.weight(.bold)
        )
        .foregroundStyle(
            .white
        )
        .padding(
            .horizontal,
            9
        )
        .padding(
            .vertical,
            6
        )
        .background(
            .black.opacity(0.52),
            in: Capsule()
        )

    }


    // MARK: - Emotion Badge

    private func emotionBadge(
        _ emotion: EmotionTag
    ) -> some View {

        HStack(
            spacing: 5
        ) {

            Text(
                emotion.imageName
            )

            Text(
                emotion.label
            )
            .lineLimit(1)

        }
        .font(
            .caption2.weight(.bold)
        )
        .foregroundStyle(
            .white
        )
        .padding(
            .horizontal,
            9
        )
        .padding(
            .vertical,
            6
        )
        .background(
            .black.opacity(0.52),
            in: Capsule()
        )

    }

}


// MARK: - Preview

#Preview("Placeholder") {

    MomentCardFace(
        experience: .placeholder
    )
    .frame(
        width: 210,
        height: 280
    )
    .padding()

}


#Preview("Mock Data") {

    MomentCardFace(
        experience: .mock
    )
    .frame(
        width: 210,
        height: 280
    )
    .padding()

}

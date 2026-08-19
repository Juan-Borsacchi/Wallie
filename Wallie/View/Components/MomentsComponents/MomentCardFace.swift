//
//  Momes.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct MomentCardFace: View {
    let experience: Experience

    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.systemGray5))
            .overlay {
                if experience.isPlaceholder {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                    } else if let data = experience.images.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                }
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    )
            }

    private func ratingBadge(_ quality: QualityRating) -> some View {
        HStack(spacing: 5) {
            Text(quality.imageName)
            Text(quality.label)
                .lineLimit(1)
        }
        .font(.caption2.weight(.bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(.black.opacity(0.52), in: Capsule())
    }

    private func emotionBadge(_ emotion: EmotionTag) -> some View {
        HStack(spacing: 5) {
            Text(emotion.imageName)
            Text(emotion.label)
                .lineLimit(1)
        }
        .font(.caption2.weight(.bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(.black.opacity(0.52), in: Capsule())
    }
}

#Preview("Placeholder") {
    MomentCardFace(experience: .placeholder)
        .frame(width: 210, height: 280)
        .padding()
}

#Preview("Mock Data") {
    MomentCardFace(experience: .mock)
        .frame(width: 210, height: 280)
        .padding()
}

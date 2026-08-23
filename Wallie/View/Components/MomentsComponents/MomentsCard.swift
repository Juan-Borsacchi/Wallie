//
//  MomentsCard.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 21/08/26.
//

import SwiftUI

struct MomentsCard: View {
    let experience: Experience
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemGray5))
               
                    if experience.isPlaceholder {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                        
                    } else if let data = experience.images.first,
                              let uiImage = UIImage(data: data) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .clipped()
                        
                    } else {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                
                
                   
                
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                )
            }
        
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
    MomentsCard(experience: .placeholder)
        .frame(width: 210, height: 280)
        .padding()
}

#Preview("Mock Data") {
    MomentsCard(experience: .mock)
        .frame(width: 210, height: 280)
        .padding()
}

//
//  XpMoodPicker.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI

struct XpMoodPicker: View {
    @Binding var selectedQuality: QualityRating?
    @Binding var selectedEmotion: EmotionTag?
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Como foi?")
                    .font(.subheadline.weight(.semibold))
                
                HStack(spacing: 8) {
                    ForEach(QualityRating.allCases) { rating in
                        let isSelected = selectedQuality == rating
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedQuality = isSelected ? nil : rating
                            }
                        } label: {
                            VStack(spacing: 5) {
                                Image(rating.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                
                                Text(rating.label)
                                    .font(.caption2.weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(isSelected ? Color.accentColor.opacity(0.18) : Color(.systemGray6))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.clear, lineWidth: 1.5)
                            }
                            .foregroundStyle(isSelected ? Color.accentColor : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Como se sentiu?")
                    .font(.subheadline.weight(.semibold))
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(EmotionTag.allCases) { tag in
                        let isSelected = selectedEmotion == tag
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedEmotion = isSelected ? nil : tag
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(tag.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                
                                Text(tag.label)
                                    .font(.caption2.weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption2)
                                }
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(isSelected ? Color.accentColor.opacity(0.18) : Color(.systemGray6))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.clear, lineWidth: 1.5)
                            }
                            .foregroundStyle(isSelected ? Color.accentColor : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var quality: QualityRating? = nil
        @State private var emotion: EmotionTag? = nil
        
        var body: some View {
            XpMoodPicker(selectedQuality: $quality, selectedEmotion: $emotion)
                .padding()
                .background(Color(.systemGroupedBackground))
        }
    }
    
    return PreviewWrapper()
}

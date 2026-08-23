//
//  MomentsCaptionView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 21/08/26.
//

import SwiftUI

struct ExperienceCaptionText: View {
    let experience: Experience

    var body: some View {
        Text(experience.title.isEmpty ? "Sem título" : experience.title)
            .font(.title3.bold())
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.horizontal, 30)
    }
}

struct MomentsCaption: View {
    let displayMode: DisplayMode
    let focusedExperience: Experience?
    let visibleBookExperiences: [Experience]
    var isSingleItem: Bool = false
    
    var body: some View {
        switch displayMode {
        case .stack:
            if let experience = focusedExperience {
                ExperienceCaptionText(experience: experience)
            }
        case .carousel:
            if let experience = focusedExperience {
                ExperienceCaptionText(experience: experience)
            }
        case .book:
            if visibleBookExperiences.count == 1, let experience = visibleBookExperiences.first {
                ExperienceCaptionText(experience: experience)
            } else if visibleBookExperiences.count >= 2 {
                HStack(spacing: 16) {
                    ForEach(visibleBookExperiences, id: \.id) { experience in
                        ExperienceCaptionText(experience: experience)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

//
//  MomentsToolBar.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 21/08/26.
//

import SwiftUI

struct MomentsToolBar: View {
    let hasExperiences: Bool
    let displayModeIcon: String
    let onCycleMode: () -> Void
    
    var body: some View {
        HStack {
            Title(title: "Momentos", subtitle: "")
                .foregroundStyle(.white)
            
            Spacer()
            
            if hasExperiences {
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        onCycleMode()
                    }
                } label: {
                    Image(systemName: displayModeIcon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
    }
}

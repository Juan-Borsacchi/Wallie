//
//  MoodPickerRow.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI

struct MoodPickerRow: View {
    @Binding var selectedMood: String

    private let humores = ["😄", "🙂", "😐", "😔", "😢", "😡", "🥳", "😴"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(humores, id: \.self) { humor in
                    Text(humor)
                        .font(.system(size: 28))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(selectedMood == humor ? Color.accentColor.opacity(0.15) : .clear)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(selectedMood == humor ? Color.accentColor : .clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedMood = humor
                            }
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

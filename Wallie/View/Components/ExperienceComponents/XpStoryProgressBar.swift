//
//  XpStoryProgressBar.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI

struct XpStoryProgressBar: View {
    let count: Int
    let selectedIndex: Int
    let progress: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { index in
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.35))
                        Capsule()
                            .fill(Color.white)
                            .frame(width: barWidth(for: index, totalWidth: proxy.size.width))
                    }
                }
                .frame(height: 3)
            }
        }
    }
    
    private func barWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        if index < selectedIndex { return totalWidth }
        if index == selectedIndex { return totalWidth * CGFloat(progress) }
        return 0
    }
}

#Preview {
    XpStoryProgressBar(count: 3, selectedIndex: 1, progress: 0.5)
}

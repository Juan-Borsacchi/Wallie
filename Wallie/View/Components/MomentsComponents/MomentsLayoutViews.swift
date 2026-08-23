//
//  MomentsLayoutViews.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct MomentCardStack: View {
    let items: [Experience]
    var cardWidth: CGFloat = 210
    var onFocusChange: (Experience) -> Void = { _ in }
    var onTapFocused: (Experience) -> Void = { _ in }
    
    @State private var focusedIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var incomingID: UUID?
    @State private var incomingExtraOffset: CGFloat = 0
    
    private let horizontalStep: CGFloat = 54
    private let verticalStep: CGFloat = -16
    private let scaleStep: CGFloat = 0.10
    private let maxVisible = 6
    
    private let cardAnimation: Animation = .spring(response: 0.45, dampingFraction: 0.82)
    
    private var cardHeight: CGFloat { cardWidth * 1.3 }
    
    var body: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                cardView(item: item, index: index)
            }
        }
        .frame(height: cardHeight + 30)
        .onChange(of: focusedIndex) { _, newValue in
            if items.indices.contains(newValue) {
                onFocusChange(items[newValue])
            }
        }
        .onAppear {
            if items.indices.contains(focusedIndex) {
                onFocusChange(items[focusedIndex])
            }
        }
    }
    
    private func circularDistance(from index: Int) -> Int {
        let count = items.count
        guard count > 0 else { return 0 }
        let raw = index - focusedIndex
        return ((raw % count) + count) % count
    }
    
    @ViewBuilder
    private func cardView(item: Experience, index: Int) -> some View {
        let distance = circularDistance(from: index)
        let isFocused = distance == 0
        let isIncoming = item.id == incomingID
        let visible = isIncoming || distance < min(maxVisible, items.count)
        
        if visible {
            let depth = CGFloat(distance)
            let xOffset: CGFloat = {
                if isIncoming { return incomingExtraOffset }
                if isFocused { return dragOffset }
                return horizontalStep * depth
            }()
            let yOffset = verticalStep * depth
            let scale = isFocused ? 1 : 1 - (scaleStep * depth)
            let zIndexValue: Double = isIncoming ? Double(items.count) + 5 : Double(items.count) - Double(distance)
            
            MomentsCard(experience: item)
                .frame(width: cardWidth, height: cardHeight)
                .offset(x: xOffset, y: yOffset)
                .scaleEffect(scale)
                .zIndex(zIndexValue)
                .shadow(color: .black.opacity(isFocused ? 0.3 : 0.18), radius: isFocused ? 16 : 8, x: 4, y: 8)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            guard isFocused else { return }
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            guard isFocused else { return }
                            handleDrag(translation: value.translation.width)
                        }
                )
                .onTapGesture {
                    if isFocused {
                        onTapFocused(item)
                    } else {
                        incomingID = nil
                        withAnimation(cardAnimation) { focusedIndex = index }
                    }
                }
        }
    }
    
    private func handleDrag(translation: CGFloat) {
        let threshold: CGFloat = 60
        if translation < -threshold {
            withAnimation(cardAnimation) {
                nextCard()
                dragOffset = 0
            }
        } else if translation > threshold {
            goToPreviousCardFromOutside()
        } else {
            withAnimation(cardAnimation) { dragOffset = 0 }
        }
    }
    
    private func nextCard() {
        guard !items.isEmpty else { return }
        focusedIndex = (focusedIndex + 1) % items.count
    }
    
    private func goToPreviousCardFromOutside() {
        guard !items.isEmpty else { return }
        let count = items.count
        let newFocusedIndex = (focusedIndex - 1 + count) % count
        let incoming = items[newFocusedIndex]
        incomingID = incoming.id
        incomingExtraOffset = cardWidth * 2.2
        withAnimation(cardAnimation) {
            focusedIndex = newFocusedIndex
            incomingExtraOffset = 0
            dragOffset = 0
        }
        let capturedID = incoming.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if incomingID == capturedID { incomingID = nil }
        }
    }
}

struct MomentCarousel: View {
    let items: [Experience]
    var onFocusChange: (Experience) -> Void = { _ in }
    var onTapFocused: (Experience) -> Void = { _ in }
    
    @State private var scrolledID: UUID?
    
    var body: some View {
        VStack(spacing: 14) {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width * 0.62
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(items) { item in
                            MomentsCard(experience: item)
                                .frame(width: cardWidth, height: cardWidth * 1.3)
                                .scrollTransition(axis: .horizontal) { content, phase in content
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                }
                                .id(item.id)
                                .onTapGesture { onTapFocused(item) }
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, (geometry.size.width - cardWidth) / 2)
                }
                .scrollPosition(id: $scrolledID)
                .scrollTargetBehavior(.viewAligned)
            }
            .frame(height: 280)
            
            if items.count > 1 {
                HStack(spacing: 6) {
                    ForEach(items) { item in
                        Circle()
                            .fill(scrolledID == item.id ? Color.white : Color.white.opacity(0.35))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 50)
            }
        }
        .onChange(of: scrolledID) { _, newID in
            if let item = items.first(where: { $0.id == newID }) {
                onFocusChange(item)
            }
        }
        .onAppear {
            if scrolledID == nil { scrolledID = items.first?.id }
            if let first = items.first { onFocusChange(first) }
        }
    }
}

#Preview("Stack") {
    MomentCardStack(items: [.mock, .placeholder])
        .padding(.top, 40)
}

#Preview("Carousel") {
    MomentCarousel(items: [.mock, .placeholder])
        .padding(.top, 40)
}

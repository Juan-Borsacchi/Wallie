//
//  BookCard.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 21/08/26.
//

import SwiftUI

enum BookTurnDirection {
    case forward
    case backward
}

struct BookView: View {

    var experiences: [Experience]
    var onTapExperience: ((Experience) -> Void)?
    var onVisibleExperiencesChange: (([Experience]) -> Void)?

    @State private(set) var currentPage: Int = -1
    @State private(set) var rotation: Double = 0
    @State private(set) var isTurning = false
    @State private(set) var turnDirection: BookTurnDirection?

    let pageWidth: CGFloat = 180
    let pageHeight: CGFloat = 260
    let dragDistance: CGFloat = 250
    let turnThreshold: Double = 90

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                BookStaticPage(
                    index: baseLeftIndex,
                    experiences: experiences,
                    size: CGSize(width: pageWidth, height: pageHeight),
                    onTap: onTapExperience
                )
                                
                BookStaticPage(
                    index: baseRightIndex,
                    experiences: experiences,
                    size: CGSize(width: pageWidth, height: pageHeight),
                    onTap: onTapExperience
                )
            }

            if isTurning, let direction = turnDirection, let frontIndex = turningFrontIndex {
                BookTurningPage(
                    frontIndex: frontIndex,
                    backIndex: turningBackIndex,
                    experiences: experiences,
                    angle: rotation,
                    direction: direction,
                    size: CGSize(width: pageWidth, height: pageHeight)
                )
                .offset(x: direction == .forward ? (pageWidth / 2 + 2.5) : -(pageWidth / 2 + 2.5))
            }
        }
        .frame(width: pageWidth * 2 + 5, height: pageHeight)
        .contentShape(Rectangle())
        .gesture(bookGesture)
        .onAppear(perform: updateVisibleExperiences)
        .onChange(of: currentPage) { _, _ in updateVisibleExperiences() }
        .onChange(of: experiences.count) { _, _ in handleExperiencesCountChange() }
    }
}

private struct BookStaticPage: View {
    let index: Int?
    let experiences: [Experience]
    let size: CGSize
    let onTap: ((Experience) -> Void)?

    var body: some View {
        Group {
            if let index = index, experiences.indices.contains(index) {
                MomentsCard(experience: experiences[index])
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTap?(experiences[index])
                    }
            } else {
                Color.clear
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

private struct BookTurningPage: View {
    let frontIndex: Int
    let backIndex: Int?
    let experiences: [Experience]
    let angle: Double
    let direction: BookTurnDirection
    let size: CGSize

    var body: some View {
        ZStack {
            if experiences.indices.contains(frontIndex) {
                MomentsCard(experience: experiences[frontIndex])
                    .frame(width: size.width, height: size.height)
                    .opacity(angle < 90 ? 1 : 0)
            }

            if let backIndex = backIndex, experiences.indices.contains(backIndex) {
                MomentsCard(experience: experiences[backIndex])
                    .frame(width: size.width, height: size.height)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(angle >= 90 ? 1 : 0)
            } else {
                Color.clear
                    .frame(width: size.width, height: size.height)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .frame(width: size.width, height: size.height)
        .rotation3DEffect(
            .degrees(direction == .forward ? -angle : angle),
            axis: (x: 0, y: 1, z: 0),
            anchor: direction == .forward ? .leading : .trailing,
            perspective: 0.65
        )
        .shadow(
            color: .black.opacity(angle > 5 ? 0.28 : 0),
            radius: 10,
            x: direction == .forward ? -5 : 5,
            y: 4
        )
    }
}

extension BookView {
    
    private var bookGesture: some Gesture {
        DragGesture(minimumDistance: 15)
            .onChanged(handleDragChange)
            .onEnded(handleDragEnd)
    }

    private func handleDragChange(_ value: DragGesture.Value) {
        guard !isTurning else { return }

        let translation = value.translation.width

        if translation < -10 {
            guard canGoForward else { return }
            startTurn(direction: .forward, translation: -translation)
        } else if translation > 10 {
            guard canGoBack else { return }
            startTurn(direction: .backward, translation: translation)
        }
    }

    private func startTurn(direction: BookTurnDirection, translation: CGFloat) {
        turnDirection = direction
        isTurning = true
        let progress = min(max(translation / dragDistance, 0), 1)
        rotation = progress * 180
    }

    private func handleDragEnd(_ value: DragGesture.Value) {
        guard isTurning, let direction = turnDirection else { return }

        let translation = abs(value.translation.width)
        let progress = min(max(translation / dragDistance, 0), 1)
        
        if progress > 0.5 {
            finishTurn(direction: direction)
        } else {
            cancelTurn()
        }
    }

    private func finishTurn(direction: BookTurnDirection) {
        withAnimation(.easeInOut(duration: 0.45)) {
            rotation = 180
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            let targetPage: Int = {
                switch direction {
                case .forward: return isCover ? 0 : currentPage + 2
                case .backward: return currentPage <= 0 ? -1 : currentPage - 2
                }
            }()

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                currentPage = targetPage
            }

            DispatchQueue.main.async {
                resetTurnState()
            }
        }
    }

    private func cancelTurn() {
        withAnimation(.easeInOut(duration: 0.30)) {
            rotation = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            resetTurnState()
        }
    }
    
    private func resetTurnState() {
        turnDirection = nil
        isTurning = false
        rotation = 0
    }
}

extension BookView {
    
    private var isCover: Bool { currentPage == -1 }
    
    private var canGoForward: Bool {
        isCover ? experiences.count >= 2 : currentPage + 2 < experiences.count
    }
    
    private var canGoBack: Bool { !isCover }
    
    private func updateVisibleExperiences() {
        let visible: [Experience]

        if experiences.isEmpty {
            visible = []
        } else if isCover {
            visible = [experiences[0]]
        } else {
            let first = currentPage
            let second = currentPage + 1
            visible = second < experiences.count
                ? [experiences[first], experiences[second]]
                : [experiences[first]]
        }

        onVisibleExperiencesChange?(visible)
    }
    
    private func handleExperiencesCountChange() {
        if currentPage >= experiences.count {
            if experiences.isEmpty {
                currentPage = -1
            } else {
                let lastEvenPage = max(0, (experiences.count - 1) / 2 * 2)
                currentPage = lastEvenPage
            }
        }
        updateVisibleExperiences()
    }
}

extension BookView {
    
    var baseLeftIndex: Int? {
        if !isTurning {
            return isCover ? nil : currentPage
        }

        if turnDirection == .forward {
            if isCover { return experiences.indices.contains(0) ? 0 : nil }
            return experiences.indices.contains(currentPage) ? currentPage : nil
        } else if turnDirection == .backward {
            let targetPage = currentPage - 2
            return experiences.indices.contains(targetPage) ? targetPage : nil
        }
        return nil
    }

    var baseRightIndex: Int? {
        if !isTurning {
            if isCover { return experiences.indices.contains(0) ? 0 : nil }
            let index = currentPage + 1
            return experiences.indices.contains(index) ? index : nil
        }

        if turnDirection == .forward {
            if isCover { return experiences.indices.contains(1) ? 1 : nil }
            let targetPage = currentPage + 3
            return experiences.indices.contains(targetPage) ? targetPage : nil
        } else if turnDirection == .backward {
            let currentRight = currentPage + 1
            return experiences.indices.contains(currentRight) ? currentRight : nil
        }
        return nil
    }
    
    var turningFrontIndex: Int? {
        guard let direction = turnDirection else { return nil }
        switch direction {
        case .forward:
            if isCover { return experiences.indices.contains(0) ? 0 : nil }
            let index = currentPage + 1
            return experiences.indices.contains(index) ? index : nil
        case .backward:
            let index = currentPage
            return experiences.indices.contains(index) ? index : nil
        }
    }
    
    var turningBackIndex: Int? {
        guard let direction = turnDirection else { return nil }
        switch direction {
        case .forward:
            if isCover { return experiences.indices.contains(0) ? 0 : nil }
            let index = currentPage + 2
            return experiences.indices.contains(index) ? index : nil
        case .backward:
            if currentPage == 0 { return experiences.indices.contains(0) ? 0 : nil }
            let index = currentPage - 1
            return experiences.indices.contains(index) ? index : nil
        }
    }
}

#Preview {
    BookPreviewWrapper()
}

private struct BookPreviewWrapper: View {
    @State private var experiences: [Experience] = [
        .mock, .mock, .mock, .mock
    ]
    var body: some View {
        ZStack {
            Color.gray.opacity(0.15)
                .ignoresSafeArea()

            BookView(experiences: experiences)
        }
    }
}

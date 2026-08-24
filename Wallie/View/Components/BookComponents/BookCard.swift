//
//  BookCard.swift
//  Wallie
//
//  Created by Felipe Colares Cardoso on 22/08/26.
//

import SwiftUI

private enum BookTurnDirection {
    case forward
    case backward
}

enum BookPageSide {
    case left
    case right
}

struct BookView: View {
    var experiences: [Experience]
    var onTapExperience: ((Experience) -> Void)?
    var onVisibleExperiencesChange: (([Experience?]) -> Void)?

    @State private var currentPage: Int = -3
    @State private var rotation: Double = 0
    @State private var isTurning = false
    @State private var turnDirection: BookTurnDirection?
    @State private var showBookBackground = false

    let pageWidth: CGFloat = 180
    let pageHeight: CGFloat = 260
    let coverSizeIncrease: CGFloat = 10
    let bookBackgroundHorizontalPadding: CGFloat = 15
    let bookBackgroundVerticalPadding: CGFloat = 15
    let dragDistance: CGFloat = 250

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.verdeEscuro)
                .frame(
                    width: pageWidth * 2 + bookBackgroundHorizontalPadding,
                    height: pageHeight + bookBackgroundVerticalPadding
                )
                .opacity(showBookBackground ? 1 : 0)

            VStack {
                Text("Deslize para os lados para virar as páginas.")
                    .frame(width: 120)
                    .offset(y: -20)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)

                Image(systemName: "book")
                    .font(.largeTitle)
                    .foregroundStyle(.black)

                Image(systemName: "hand.point.up.left.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                    .offset(y: -20)
                    .phaseAnimator([-18.0, 36.0]) { content, xOffset in
                        content.offset(x: xOffset)
                    } animation: { _ in
                        .easeInOut(duration: 0.8)
                    }
            }
            .padding(.leading, -160)

            ZStack {
                HStack(spacing: 0) {
                    BookStaticPage(
                        index: baseLeftIndex,
                        side: .left,
                        experiences: experiences,
                        backCoverLeftIndex: backCoverLeftIndex,
                        size: CGSize(width: pageWidth, height: pageHeight),
                        coverSizeIncrease: coverSizeIncrease,
                        onTap: onTapExperience
                    )

                    BookStaticPage(
                        index: baseRightIndex,
                        side: .right,
                        experiences: experiences,
                        backCoverLeftIndex: backCoverLeftIndex,
                        size: CGSize(width: pageWidth, height: pageHeight),
                        coverSizeIncrease: coverSizeIncrease,
                        onTap: onTapExperience
                    )
                }

                if isTurning,
                   let direction = turnDirection,
                   let frontIndex = turningFrontIndex {
                    
                    BookTurningPage(
                        frontIndex: frontIndex,
                        backIndex: turningBackIndex,
                        experiences: experiences,
                        backCoverLeftIndex: backCoverLeftIndex,
                        angle: rotation,
                        direction: direction,
                        size: CGSize(width: pageWidth, height: pageHeight),
                        coverSizeIncrease: coverSizeIncrease
                    )
                    .offset(x: direction == .forward ? (pageWidth / 2 + 2.5) : -(pageWidth / 2 + 2.5))
                }
            }
            .frame(width: pageWidth * 2 + 5, height: pageHeight)
            .contentShape(Rectangle())
            .gesture(bookGesture)
            .onAppear {
                updateVisibleExperiences()
                showBookBackground = isBookOpen
            }
            .onChange(of: currentPage) { _, _ in
                updateVisibleExperiences()
            }
            .onChange(of: isBookOpen) { _, isOpen in
                if isOpen {
                    withAnimation(.easeOut(duration: 0.35)) {
                        showBookBackground = true
                    }
                } else {
                    showBookBackground = false
                }
            }
            .onChange(of: experiences.count) { _, _ in
                handleExperiencesCountChange()
            }
        }
    }
}

private func isOuterCoverIndex(_ index: Int?, backCoverLeftIndex: Int) -> Bool {
    guard let index else {
        return false
    }
    return index == -2 || index == backCoverLeftIndex + 1
}

private struct BookStaticPage: View {
    let index: Int?
    let side: BookPageSide
    let experiences: [Experience]
    let backCoverLeftIndex: Int
    let size: CGSize
    let coverSizeIncrease: CGFloat
    let onTap: ((Experience) -> Void)?

    var body: some View {
        Group {
            if let index {
                BookPageContent(
                    index: index,
                    side: side,
                    experiences: experiences,
                    backCoverLeftIndex: backCoverLeftIndex,
                    onTap: onTap
                )
            } else {
                Color.clear
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
    }

    private var frameSize: CGSize {
        let isCover = isOuterCoverIndex(index, backCoverLeftIndex: backCoverLeftIndex)
        return CGSize(
            width: size.width + (isCover ? coverSizeIncrease : 0),
            height: size.height + (isCover ? coverSizeIncrease : 0)
        )
    }
}

private struct BookPageContent: View {
    let index: Int
    let side: BookPageSide
    let experiences: [Experience]
    let backCoverLeftIndex: Int
    let onTap: ((Experience) -> Void)?

    var body: some View {
        Group {
            if index == -2 {
                BookCover()
            } else if index == -1 {
                BookCoverBack()
            } else if index == backCoverLeftIndex {
                BookCoverBack()
            } else if index == backCoverLeftIndex + 1 {
                BookCover()
            } else if experiences.indices.contains(index) {
                MomentsCard(experience: experiences[index])
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTap?(experiences[index])
                    }
            } else if index == experiences.count {
                Image("PaginaVazia")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(y: 1.05)
            } else {
                Color.clear
            }
        }
        .clipShape(outerCornerShape)
    }

    private var outerCornerShape: UnevenRoundedRectangle {
        switch side {
        case .left:
            return UnevenRoundedRectangle(
                topLeadingRadius: 20,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
        case .right:
            return UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 20,
                topTrailingRadius: 20
            )
        }
    }
}

private struct BookTurningPage: View {
    let frontIndex: Int
    let backIndex: Int?
    let experiences: [Experience]
    let backCoverLeftIndex: Int
    let angle: Double
    let direction: BookTurnDirection
    let size: CGSize
    let coverSizeIncrease: CGFloat

    var body: some View {
        ZStack {
            BookPageContent(
                index: frontIndex,
                side: frontSide,
                experiences: experiences,
                backCoverLeftIndex: backCoverLeftIndex,
                onTap: nil
            )
            .frame(width: frameSize.width, height: frameSize.height)
            .opacity(angle < 90 ? 1 : 0)

            if let backIndex {
                BookPageContent(
                    index: backIndex,
                    side: backSide,
                    experiences: experiences,
                    backCoverLeftIndex: backCoverLeftIndex,
                    onTap: nil
                )
                .frame(width: frameSize.width, height: frameSize.height)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(angle >= 90 ? 1 : 0)
            } else {
                Color.clear
                    .frame(width: frameSize.width, height: frameSize.height)
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .rotation3DEffect(
            .degrees(direction == .forward ? -angle : angle),
            axis: (x: 0, y: 1, z: 0),
            anchor: direction == .forward ? .leading : .trailing,
            perspective: 0.65
        )
    }

    private var frontSide: BookPageSide {
        direction == .forward ? .right : .left
    }

    private var backSide: BookPageSide {
        direction == .forward ? .left : .right
    }

    private var frameSize: CGSize {
        let frontIsCover = isOuterCoverIndex(frontIndex, backCoverLeftIndex: backCoverLeftIndex)
        let backIsCover = isOuterCoverIndex(backIndex, backCoverLeftIndex: backCoverLeftIndex)
        let isCover = frontIsCover || backIsCover
        
        return CGSize(
            width: size.width + (isCover ? coverSizeIncrease : 0),
            height: size.height + (isCover ? coverSizeIncrease : 0)
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
            let targetPage: Int

            switch direction {
            case .forward:
                targetPage = currentPage + 2
            case .backward:
                targetPage = currentPage - 2
            }

            var transaction = Transaction()
            transaction.disablesAnimations = true

            withTransaction(transaction) {
                currentPage = targetPage
                turnDirection = nil
                isTurning = false
                rotation = 0
            }
        }
    }

    private func cancelTurn() {
        withAnimation(.easeInOut(duration: 0.30)) {
            rotation = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            turnDirection = nil
            isTurning = false
            rotation = 0
        }
    }
}

extension BookView {
    private var backCoverLeftIndex: Int {
        if experiences.isEmpty { return 0 }
        return ((experiences.count + 1) / 2) * 2
    }

    private var isCover: Bool {
        currentPage == -3
    }

    private var isBackCover: Bool {
        currentPage == backCoverLeftIndex + 1
    }

    var isBookOpen: Bool {
        !isCover && !isBackCover
    }

    private var canGoForward: Bool {
        currentPage < backCoverLeftIndex
    }

    private var canGoBack: Bool {
        currentPage > -2
    }

    private func updateVisibleExperiences() {
        if isCover || isBackCover {
            onVisibleExperiencesChange?([nil, nil])
        } else {
            let leftExp = experiences.indices.contains(currentPage) ? experiences[currentPage] : nil
            let rightExp = experiences.indices.contains(currentPage + 1) ? experiences[currentPage + 1] : nil
            
            onVisibleExperiencesChange?([leftExp, rightExp])
        }
    }

    private func handleExperiencesCountChange() {
        if currentPage > backCoverLeftIndex {
            currentPage = backCoverLeftIndex
        }
        updateVisibleExperiences()
    }
}

extension BookView {
    var baseLeftIndex: Int? {
        if !isTurning { return currentPage }
        guard let direction = turnDirection else { return currentPage }

        switch direction {
        case .forward:
            return currentPage
        case .backward:
            return currentPage - 2
        }
    }

    var baseRightIndex: Int? {
        if !isTurning { return currentPage + 1 }
        guard let direction = turnDirection else { return currentPage + 1 }

        switch direction {
        case .forward:
            return currentPage + 3
        case .backward:
            return currentPage + 1
        }
    }

    var turningFrontIndex: Int? {
        guard let direction = turnDirection else { return nil }

        switch direction {
        case .forward:
            return currentPage + 1
        case .backward:
            return currentPage
        }
    }

    var turningBackIndex: Int? {
        guard let direction = turnDirection else { return nil }

        switch direction {
        case .forward:
            return currentPage + 2
        case .backward:
            return currentPage - 1
        }
    }
}

#Preview {
    BookPreviewWrapper()
}

private struct BookPreviewWrapper: View {
    @State private var experiences: [Experience] = [
        .mock, .mock, .mock, .mock, .mock
    ]

    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.15)
                .ignoresSafeArea()

            BookView(experiences: experiences)
        }
    }
}

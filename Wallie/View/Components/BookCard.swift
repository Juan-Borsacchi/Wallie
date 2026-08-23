//
//  BookCard.swift
//  Wallie
//

import SwiftUI

private enum BookTurnDirection {
    case forward
    case backward
}


struct BookView: View {

    var experiences: [Experience]

    var onTapExperience: ((Experience) -> Void)?
    var onVisibleExperiencesChange: (([Experience?]) -> Void)?

    @State private var currentPage: Int = -3

    @State private var rotation: Double = 0
    @State private var isTurning = false
    @State private var turnDirection: BookTurnDirection?

    let pageWidth: CGFloat = 180
    let pageHeight: CGFloat = 260

    let dragDistance: CGFloat = 250

    var body: some View {
        
        ZStack{
            
                Rectangle()
                    .fill(.verdeEscuro)
                    .frame(maxWidth: 28, maxHeight: 255)
                    .cornerRadius(5)
            VStack{
                Text("Deslize para os lados para virar as páginas.")
                    .frame(width: 120)
                    .offset(y: -20)
                    .foregroundStyle(.black)
                Image(systemName: "book")
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                    
                Image(systemName: "hand.point.up.left.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                    .offset(y: -20)
                    .phaseAnimator([-18.0, 36.0]) { content, xOffset in
                                        content
                                            .offset(x: xOffset)
                                    } animation: { _ in
                                        .easeInOut(duration: 0.8)
                                    }
                
            }.padding(.leading, -160)
            
               
            
            
            
            ZStack {
                                
                HStack(spacing: 0) {
                    
                    BookStaticPage(
                        index: baseLeftIndex,
                        experiences: experiences,
                        backCoverLeftIndex: backCoverLeftIndex,
                        size: CGSize(
                            width: pageWidth,
                            height: pageHeight
                        ),
                        onTap: onTapExperience
                    )
                    
                    BookStaticPage(
                        index: baseRightIndex,
                        experiences: experiences,
                        backCoverLeftIndex: backCoverLeftIndex,
                        size: CGSize(
                            width: pageWidth,
                            height: pageHeight
                        ),
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
                        size: CGSize(
                            width: pageWidth,
                            height: pageHeight
                        )
                    )
                    .offset(
                        x: direction == .forward
                        ? (pageWidth / 2 + 2.5)
                        : -(pageWidth / 2 + 2.5)
                    )
                }
            }
            .frame(
                width: pageWidth * 2 + 5,
                height: pageHeight
            )
            .contentShape(Rectangle())
            .gesture(bookGesture)
            
            .onAppear {
                updateVisibleExperiences()
            }
            
            .onChange(of: currentPage) { _, _ in
                updateVisibleExperiences()
            }
            
            .onChange(of: experiences.count) { _, _ in
                handleExperiencesCountChange()
            }
        }}
}


private struct BookStaticPage: View {

    let index: Int?

    let experiences: [Experience]

    let backCoverLeftIndex: Int

    let size: CGSize

    let onTap: ((Experience) -> Void)?


    var body: some View {

        Group {

            if let index {

                BookPageContent(
                    index: index,
                    experiences: experiences,
                    backCoverLeftIndex: backCoverLeftIndex,
                    onTap: onTap
                )

            } else {

                Color.clear
            }
        }
        .frame(
            width: size.width,
            height: size.height
        )
    }
}



private struct BookPageContent: View {

    let index: Int

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
                
                MomentsCard(
                    experience: experiences[index]
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    
                    onTap?(experiences[index])
                    
                }}else if index == experiences.count {
                    
                    Image("PaginaVazia")
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(y: 1.05)
                        .clipShape(.rect(cornerRadius: 20))
                    
            } else {
                Color.clear
            }
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


    var body: some View {

        ZStack {

            BookPageContent(
                index: frontIndex,
                experiences: experiences,
                backCoverLeftIndex: backCoverLeftIndex,
                onTap: nil
            )
            .frame(
                width: size.width,
                height: size.height
            )
            .opacity(
                angle < 90 ? 1 : 0
            )

            if let backIndex {

                BookPageContent(
                    index: backIndex,
                    experiences: experiences,
                    backCoverLeftIndex: backCoverLeftIndex,
                    onTap: nil
                )
                .frame(
                    width: size.width,
                    height: size.height
                )
                .rotation3DEffect(
                    .degrees(180),
                    axis: (
                        x: 0,
                        y: 1,
                        z: 0
                    )
                )
                .opacity(
                    angle >= 90 ? 1 : 0
                )

            } else {

                Color.clear
                    .frame(
                        width: size.width,
                        height: size.height
                    )
            }
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
        .frame(
            width: size.width,
            height: size.height
        )
        .rotation3DEffect(
            .degrees(
                direction == .forward
                ? -angle
                : angle
            ),
            axis: (
                x: 0,
                y: 1,
                z: 0
            ),
            anchor: direction == .forward
            ? .leading
            : .trailing,
            perspective: 0.65
        )

    }
}


extension BookView {

    private var bookGesture: some Gesture {

        DragGesture(
            minimumDistance: 15
        )
        .onChanged(
            handleDragChange
        )
        .onEnded(
            handleDragEnd
        )
    }


    private func handleDragChange(
        _ value: DragGesture.Value
    ) {

        guard !isTurning else {
            return
        }

        let translation = value.translation.width

        if translation < -10 {

            guard canGoForward else {
                return
            }

            startTurn(
                direction: .forward,
                translation: -translation
            )

        } else if translation > 10 {

            guard canGoBack else {
                return
            }

            startTurn(
                direction: .backward,
                translation: translation
            )
        }
    }


    private func startTurn(
        direction: BookTurnDirection,
        translation: CGFloat
    ) {

        turnDirection = direction

        isTurning = true

        let progress = min(
            max(
                translation / dragDistance,
                0
            ),
            1
        )

        rotation = progress * 180
    }


    private func handleDragEnd(
        _ value: DragGesture.Value
    ) {

        guard isTurning,
              let direction = turnDirection
        else {
            return
        }

        let translation = abs(
            value.translation.width
        )

        let progress = min(
            max(
                translation / dragDistance,
                0
            ),
            1
        )


        if progress > 0.5 {

            finishTurn(
                direction: direction
            )

        } else {

            cancelTurn()
        }
    }


    private func finishTurn(
        direction: BookTurnDirection
    ) {

        withAnimation(
            .easeInOut(
                duration: 0.45
            )
        ) {

            rotation = 180
        }


        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.45
        ) {

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

        withAnimation(
            .easeInOut(
                duration: 0.30
            )
        ) {

            rotation = 0
        }


        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.30
        ) {

            turnDirection = nil

            isTurning = false

            rotation = 0
        }
    }
}

extension BookView {

    private var backCoverLeftIndex: Int {

        if experiences.isEmpty {
            return 0
        }

        return (
            (experiences.count + 1) / 2
        ) * 2
    }



    private var isCover: Bool {

        currentPage == -2
    }


    private var isBackCover: Bool {

        currentPage == backCoverLeftIndex
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

        if !isTurning {
            return currentPage
        }

        guard let direction = turnDirection else {
            return currentPage
        }

        switch direction {

        case .forward:
            return currentPage

        case .backward:
            return currentPage - 2
        }
    }


    var baseRightIndex: Int? {

        if !isTurning {
            return currentPage + 1
        }

        guard let direction = turnDirection else {
            return currentPage + 1
        }

        switch direction {

        case .forward:
            return currentPage + 3

        case .backward:
            return currentPage + 1
        }
    }


    var turningFrontIndex: Int? {

        guard let direction = turnDirection else {
            return nil
        }

        switch direction {

        case .forward:
            return currentPage + 1

        case .backward:
            return currentPage
        }
    }


    var turningBackIndex: Int? {

        guard let direction = turnDirection else {
            return nil
        }

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

        .mock,
        .mock,
        .mock,
        .mock,
        .mock
    ]


    var body: some View {

        ZStack {

            Color.gray
                .opacity(0.15)
                .ignoresSafeArea()


            BookView(
                experiences: experiences
            )
        }
    }
}


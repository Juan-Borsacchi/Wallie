//
//  BookCard.swift
//  Wallie
//

import SwiftUI

// MARK: - Direção da virada

private enum BookTurnDirection {
    case forward
    case backward
}


// MARK: - Book View

struct BookView: View {

    var experiences: [Experience]

    var onTapExperience: ((Experience) -> Void)?
    var onVisibleExperiencesChange: (([Experience?]) -> Void)?

    // -2 = capa
    //  0, 2, 4... = páginas das experiências
    // backCoverLeftIndex = última página especial
    @State private var currentPage: Int = -3

    @State private var rotation: Double = 0
    @State private var isTurning = false
    @State private var turnDirection: BookTurnDirection?

    let pageWidth: CGFloat = 180
    let pageHeight: CGFloat = 260

    let dragDistance: CGFloat = 250


    // MARK: - Body
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
                                        // Define como é a transição entre os valores
                                        .easeInOut(duration: 0.8)
                                    }
                
            }.padding(.leading, -160)
            
               
            
            
            
            ZStack {
                
                // MARK: Páginas estáticas
                
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
                
                
                // MARK: Página sendo virada
                
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


// MARK: - Página estática

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


// MARK: - Conteúdo de uma página

private struct BookPageContent: View {

    let index: Int

    let experiences: [Experience]

    let backCoverLeftIndex: Int

    let onTap: ((Experience) -> Void)?


    var body: some View {

        Group {

            // MARK: Capa azul

            if index == -2 {
             
                BookCover()
                /*
                Image("livro")
                    .resizable()
                    .scaledToFill()
                   // .scaleEffect(1.1)
                    .clipShape(.rect(cornerRadius: 20))
               // Rectangle()
                 //   .fill(.blue)
*/

            // MARK: Contra-capa inicial cinza

            } else if index == -1 {
                
                
                BookCoverBack()
                /*
                Image("livro")
                    .resizable()
                    .scaledToFill()
                    //.colorInver
                    .scaleEffect(x: -1, y: 1)
                    //.scaleEffect(1.1)
                    .clipShape(.rect(cornerRadius: 20))

                    */
            // MARK: Contra-capa final cinza

            } else if index == backCoverLeftIndex {

                
                BookCoverBack()
                /*Image("livro")
                    .resizable()
                    .scaledToFill()
                   // .scaleEffect(1.1)
                    .clipShape(.rect(cornerRadius: 20))
                 */

            // MARK: Capa final verde

            } else if index == backCoverLeftIndex + 1 {
                
                BookCover()
                /*
                Image("livro")
                    .resizable()
                    .scaledToFill()
                    //.colorInver
                    .scaleEffect(x: -1, y: 1)
                    //.scaleEffect(1.1)
                    .clipShape(.rect(cornerRadius: 20))
                    */
            // MARK: Experience

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
                        //.colorInver
                        .scaleEffect(y: 1.05)
                       // .scaleEffect(0.9)
                        .clipShape(.rect(cornerRadius: 20))
                    
              

            // MARK: Página vazia

            } else {
                Color.clear
            }
        }
    }
}


// MARK: - Página virando

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

            // MARK: Frente da página

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


            // MARK: Verso da página

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
       /*.shadow(
            color: .black.opacity(
                angle > 5 ? 0.28 : 0
            ),
            radius: 10,
            x: direction == .forward
            ? -5
            : 5,
            y: 4
        )*/
    }
}


// MARK: - Gesture

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


        // MARK: Próxima página

        if translation < -10 {

            guard canGoForward else {
                return
            }

            startTurn(
                direction: .forward,
                translation: -translation
            )


        // MARK: Página anterior

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


// MARK: - Estado do livro

extension BookView {


    /*
     

     0 experiences
     backCoverLeftIndex = 0

     1 experience
     backCoverLeftIndex = 2

     2 experiences
     backCoverLeftIndex = 2

     3 experiences
     backCoverLeftIndex = 4

     4 experiences
     backCoverLeftIndex = 4
     */

    private var backCoverLeftIndex: Int {

        if experiences.isEmpty { // pagina vazia?
            return 0
        }

        return (
            (experiences.count + 1) / 2
        ) * 2
    }


    // MARK: Estamos na capa inicial?

    private var isCover: Bool {

        currentPage == -2
    }


    // MARK: Estamos na capa final?

    private var isBackCover: Bool {

        currentPage == backCoverLeftIndex
    }


    // MARK: Pode avançar?

    private var canGoForward: Bool {

        currentPage < backCoverLeftIndex
    }


    // MARK: Pode voltar?

    private var canGoBack: Bool {

        currentPage > -2
    }


    // MARK: Experiences visíveis

    private func updateVisibleExperiences() {
            // Se o livro estiver totalmente fechado no início ou no fim, nenhuma página é mostrada
            if isCover || isBackCover {
                onVisibleExperiencesChange?([nil, nil])
            } else {
                // Verifica separadamente a página da ESQUERDA e a página da DIREITA
                let leftExp = experiences.indices.contains(currentPage) ? experiences[currentPage] : nil
                let rightExp = experiences.indices.contains(currentPage + 1) ? experiences[currentPage + 1] : nil
                
                // Retorna sempre 2 elementos marcando a posição (esquerda, direita)
                onVisibleExperiencesChange?([leftExp, rightExp])
            }
        }


    // MARK: Mudança na quantidade de experiences

    private func handleExperiencesCountChange() {

        if currentPage > backCoverLeftIndex {

            currentPage = backCoverLeftIndex
        }


        updateVisibleExperiences()
    }
}


// MARK: - Índices das páginas estáticas

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
            // Mantém a página esquerda atual visível
            return currentPage

        case .backward:
            // Revela a página esquerda anterior
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
            // A próxima página da direita.
            // Se estivermos chegando ao final, esse índice pode
            // ser uma página especial (contra-capa/capa final),
            // então NÃO verificamos apenas experiences.indices.
            return currentPage + 3

        case .backward:
            // Mantém a página direita atual enquanto voltamos
            return currentPage + 1
        }
    }


    var turningFrontIndex: Int? {

        guard let direction = turnDirection else {
            return nil
        }

        switch direction {

        case .forward:
            // Página direita atual que está sendo virada
            return currentPage + 1

        case .backward:
            // Página esquerda atual que está sendo virada de volta
            return currentPage
        }
    }


    var turningBackIndex: Int? {

        guard let direction = turnDirection else {
            return nil
        }

        switch direction {

        case .forward:
            // Verso da página que está virando
            return currentPage + 2

        case .backward:
            // Verso da página anterior
            return currentPage - 1
        }
    }
}


// MARK: - Preview

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


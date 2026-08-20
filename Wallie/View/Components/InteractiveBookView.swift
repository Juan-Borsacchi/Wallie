//
// InteractiveBookView.swift
// Wallie
//
// Livro interativo usando MomentCardFace
//

import SwiftUI

// MARK: - Direção da virada

private enum BookTurnDirection {
    case forward
    case backward
}

// MARK: - BookView

struct BookView: View {

    // MARK: - Dados

    @Binding var experiences: [Experience]
    var onTapExperience: ((Experience) -> Void)?

    /// Informa ao MomentsHomeView quais cards estão atualmente visíveis.
    var onVisibleExperiencesChange: (([Experience]) -> Void)?

    // MARK: - Estado

    /*
     -1 = capa
     0 = página 0 + página 1
     2 = página 2 + página 3
     4 = página 4 + página 5
     */
    @State private var currentPage: Int = -1
    @State private var rotation: Double = 0
    @State private var isTurning = false
    @State private var turnDirection: BookTurnDirection?

    // MARK: - Configuração

    private let pageWidth: CGFloat = 180
    private let pageHeight: CGFloat = 260
    private let dragDistance: CGFloat = 250
    private let turnThreshold: Double = 90

    // MARK: - Estado do livro

    private var isCover: Bool {
        currentPage == -1
    }

    private var canGoForward: Bool {
        if isCover {
            return experiences.count >= 2
        }
        return currentPage + 2 < experiences.count
    }

    /*
     Agora pode voltar do primeiro spread para a capa.
     Antes estava:
     currentPage >= 2
     e isso impedia:
     [1][2] → Capa
     */
    private var canGoBack: Bool {
        !isCover
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Livro normal
            HStack(spacing: 0) {
                baseLeftPage
                // spine // nao ficou bom
                baseRightPage
            }

            // Página que está sendo virada.
            //
            // Ela fica POR CIMA do livro.
            //
            // Isso evita que o conteúdo "teleporte"
            // durante a troca do currentPage.
            if isTurning {
                turningPage
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
            // Evita que o livro fique em uma página
            // que deixou de existir.
            if currentPage >= experiences.count {
                if experiences.isEmpty {
                    currentPage = -1
                } else {
                    let lastEvenPage =
                        max(
                            0,
                            (experiences.count - 1) / 2 * 2
                        )
                    currentPage = lastEvenPage
                }
            }
            updateVisibleExperiences()
        }
    }
}

// MARK: - Páginas de base

extension BookView {

    /*
     Esta é a parte mais importante da correção.
     Durante uma virada, o livro de fundo já assume
     a posição FINAL da página que está sendo revelada.
     Assim, quando a folha chega em 180º, não existe
     nenhuma troca visual brusca.
     */
    @ViewBuilder
    private var baseLeftPage: some View {
        if let index = baseLeftIndex {
            MomentCardFace(
                experience: experiences[index]
            )
            .frame(
                width: pageWidth,
                height: pageHeight
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onTapExperience?(
                    experiences[index]
                )
            }
        } else {
            Color.clear
                .frame(
                    width: pageWidth,
                    height: pageHeight
                )
        }
    }

    @ViewBuilder
    private var baseRightPage: some View {
        if let index = baseRightIndex {
            MomentCardFace(
                experience: experiences[index]
            )
            .frame(
                width: pageWidth,
                height: pageHeight
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onTapExperience?(
                    experiences[index]
                )
            }
        } else {
            Color.clear
                .frame(
                    width: pageWidth,
                    height: pageHeight
                )
        }
    }
}

// MARK: - Índices das páginas de base

extension BookView {

    private var baseLeftIndex: Int? {
        // ----------------------------------------
        // CAPA NORMAL
        // ----------------------------------------
        if !isTurning {
            if isCover {
                return nil
            }
            return currentPage
        }

        // ----------------------------------------
        // DURANTE VIRADA PARA FRENTE
        // ----------------------------------------
        if turnDirection == .forward {
            /*
             Capa → livro aberto
             Durante a animação:
             [1] [2]
             A capa está saindo da direita.
             */
            if isCover {
                return experiences.indices.contains(0)
                    ? 0
                    : nil
            }
            /*
             Exemplo:
             [1] [2]
             virando 2:
             [1] [3]
             A página 3 fica atrás.
             */
            return experiences.indices.contains(currentPage)
                ? currentPage
                : nil
        }

        // ----------------------------------------
        // DURANTE VIRADA PARA TRÁS
        // ----------------------------------------
        if turnDirection == .backward {
            /*
             Exemplo:
             [3] [4]
             voltando:
             [1] [2]
             A página 1 já fica atrás da folha.
             */
            let targetPage = currentPage - 2
            return experiences.indices.contains(targetPage)
                ? targetPage
                : nil
        }

        return nil
    }

    private var baseRightIndex: Int? {
        // ----------------------------------------
        // CAPA NORMAL
        // ----------------------------------------
        if !isTurning {
            if isCover {
                return experiences.indices.contains(0)
                    ? 0
                    : nil
            }
            let index = currentPage + 1
            return experiences.indices.contains(index)
                ? index
                : nil
        }

        // ----------------------------------------
        // VIRANDO PARA FRENTE
        // ----------------------------------------
        if turnDirection == .forward {
            /*
             Exemplo:
             [1] [2]
             durante a virada:
             [1] [3]
             A página 3 fica atrás da página 2.
             */
            if isCover {
                return experiences.indices.contains(1)
                    ? 1
                    : nil
            }
            let targetPage = currentPage + 3
            return experiences.indices.contains(targetPage)
                ? targetPage
                : nil
        }

        // ----------------------------------------
        // VIRANDO PARA TRÁS
        // ----------------------------------------
        if turnDirection == .backward {
            /*
             A página direita atual continua atrás
             enquanto a página esquerda é virada.
             Exemplo:
             [3] [4]
             durante a volta:
             [1] [4]
             */
            let currentRight = currentPage + 1
            return experiences.indices.contains(currentRight)
                ? currentRight
                : nil
        }

        return nil
    }
}

// MARK: - Página em movimento

extension BookView {

    @ViewBuilder
    private var turningPage: some View {
        if let direction = turnDirection {
            let frontIndex: Int? = {
                switch direction {
                case .forward:
                    if isCover {
                        return experiences.indices.contains(0)
                            ? 0
                            : nil
                    }
                    let index = currentPage + 1
                    return experiences.indices.contains(index)
                        ? index
                        : nil
                case .backward:
                    let index = currentPage
                    return experiences.indices.contains(index)
                        ? index
                        : nil
                }
            }()

            let backIndex: Int? = {
                switch direction {
                case .forward:
                    if isCover {
                        /*
                         A capa vira para se tornar
                         a página esquerda.
                         A parte de trás continua
                         representando a própria capa.
                         */
                        return experiences.indices.contains(0)
                            ? 0
                            : nil
                    }
                    let index = currentPage + 2
                    return experiences.indices.contains(index)
                        ? index
                        : nil
                case .backward:
                    if currentPage == 0 {
                        /*
                         Voltando para a capa.
                         A parte de trás da página 1
                         será a capa.
                         */
                        return experiences.indices.contains(0)
                            ? 0
                            : nil
                    }
                    let index = currentPage - 1
                    return experiences.indices.contains(index)
                        ? index
                        : nil
                }
            }()

            if let frontIndex {
                BookTurningPage(
                    front: AnyView(
                        MomentCardFace(
                            experience: experiences[frontIndex]
                        )
                    ),
                    back: backIndex.map { index in
                        AnyView(
                            MomentCardFace(
                                experience: experiences[index]
                            )
                        )
                    },
                    angle: rotation,
                    direction: direction,
                    width: pageWidth,
                    height: pageHeight
                )
                .offset(
                    x:
                        direction == .forward
                        ? pageWidth / 2 + 2.5
                        : -(pageWidth / 2 + 2.5)
                )
            }
        }
    }
}

// MARK: - Página 3D

private struct BookTurningPage: View {
    let front: AnyView
    let back: AnyView?
    let angle: Double
    let direction: BookTurnDirection
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            // Frente
            front
                .frame(
                    width: width,
                    height: height
                )
                .opacity(
                    angle < 90
                    ? 1
                    : 0
                )

            // Verso
            if let back {
                back
                    .frame(
                        width: width,
                        height: height
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
                        angle >= 90
                        ? 1
                        : 0
                    )
            } else {
                Color.clear
                    .frame(
                        width: width,
                        height: height
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
            width: width,
            height: height
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
            anchor:
                direction == .forward
                ? .leading
                : .trailing,
            perspective: 0.65
        )
        .shadow(
            color: .black.opacity(
                angle > 5
                ? 0.28
                : 0
            ),
            radius: 10,
            x: direction == .forward ? -5 : 5,
            y: 4
        )
    }
}

// MARK: - Lombada

extension BookView {
    private var spine: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.30),
                .black.opacity(0.08),
                .black.opacity(0.30)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(
            width: 5,
            height: pageHeight
        )
    }
}

// MARK: - Gesture

extension BookView {
    private var bookGesture: some Gesture {
        DragGesture(
            minimumDistance: 15
        )
        .onChanged { value in
            guard !isTurning else {
                return
            }

            let translation =
                value.translation.width

            // ------------------------------------
            // PARA FRENTE
            // ------------------------------------
            if translation < -10 {
                guard canGoForward else {
                    return
                }
                turnDirection = .forward
                isTurning = true

                let progress = min(
                    max(
                        -translation / dragDistance,
                        0
                    ),
                    1
                )
                rotation = progress * 180
            }
            // ------------------------------------
            // PARA TRÁS
            // ------------------------------------
            else if translation > 10 {
                guard canGoBack else {
                    return
                }
                turnDirection = .backward
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
        }
        .onEnded { value in
            guard isTurning,
                  let direction = turnDirection
            else {
                return
            }

            let translation =
                value.translation.width
            let progress = min(
                max(
                    abs(translation) / dragDistance,
                    0
                ),
                1
            )

            let shouldComplete =
                progress > 0.5

            if shouldComplete {
                finishTurn(
                    direction: direction
                )
            } else {
                cancelTurn()
            }
        }
    }
}

// MARK: - Finalizar virada

extension BookView {
    private func finishTurn(
        direction: BookTurnDirection
    ) {
        withAnimation(
            .easeInOut(duration: 0.45)
        ) {
            rotation = 180
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.45
        ) {
            let targetPage: Int
            switch direction {
            case .forward:
                if isCover {
                    targetPage = 0
                } else {
                    targetPage = currentPage + 2
                }
            case .backward:
                if currentPage <= 0 {
                    targetPage = -1
                } else {
                    targetPage = currentPage - 2
                }
            }

            /*
             MUITO IMPORTANTE:
             Primeiro mudamos o conteúdo do livro
             enquanto a folha ainda está parada em 180º.
             Não existe animação nessa troca.
             */
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                currentPage = targetPage
            }

            /*
             Esperamos um ciclo de renderização.
             Nesse momento:
             folha = 180º
             conteúdo atrás = novo conteúdo
             Portanto os dois lados são visualmente
             idênticos.
             Só depois removemos a folha.
             */
            DispatchQueue.main.async {
                turnDirection = nil
                isTurning = false
                rotation = 0
            }
        }
    }
}

// MARK: - Cancelar virada

extension BookView {
    private func cancelTurn() {
        withAnimation(
            .easeInOut(duration: 0.30)
        ) {
            rotation = 0
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.30
        ) {
            turnDirection = nil
            isTurning = false
        }
    }
}

// MARK: - Caption

extension BookView {
    private func updateVisibleExperiences() {
        let visible: [Experience]

        if experiences.isEmpty {
            visible = []
        } else if isCover {
            visible = [
                experiences[0]
            ]
        } else {
            let first = currentPage
            let second = currentPage + 1

            if second < experiences.count {
                visible = [
                    experiences[first],
                    experiences[second]
                ]
            } else {
                visible = [
                    experiences[first]
                ]
            }
        }

        onVisibleExperiencesChange?(visible)
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
        .mock
    ]

    var body: some View {
        ZStack {
            Color.gray.opacity(0.15)
                .ignoresSafeArea()

            BookView(
                experiences: $experiences
            )
        }
    }
}

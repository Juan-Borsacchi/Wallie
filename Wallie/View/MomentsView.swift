//
//  MomentsHomeView.swift
//  Wallie
//

import SwiftUI

struct MomentosHomeView: View {

    @Environment(WallieViewModel.self)
    var viewmodel

    // MARK: - Modo de exibição

    enum DisplayMode {

        case stack
        case carousel
        case book

    }

    @State
    private var displayMode: DisplayMode = .carousel

    // Experiência atualmente em foco.
    // No BookView, ela é atualizada conforme as páginas mudam.
    @State
    private var focusedExperience: Experience?

    @State
    private var visibleBookExperiences: [Experience] = []

    @State
    private var isShowingAddExperience = false

    @State
    private var selectedExperienceID: UUID?

    @State
    private var isShowingDetail = false

    @State
    private var isShowingAllExperiences = false


    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            header

            Spacer()

            Group {

                if viewmodel.experiences.isEmpty {

                    FirstMomentCard()
                        .onTapGesture {

                            isShowingAddExperience = true

                        }

                } else {

                    switch displayMode {

                    // MARK: Stack

                    case .stack:

                        MomentCardStack(
                            items: viewmodel.experiences,
                            onFocusChange: {

                                focusedExperience = $0

                            },
                            onTapFocused: handleTap
                        )


                    // MARK: Carousel

                    case .carousel:

                        MomentCarousel(
                            items: viewmodel.experiences,
                            onFocusChange: {

                                focusedExperience = $0

                            },
                            onTapFocused: handleTap
                        )


                    // MARK: Book

                    case .book:

                        BookView(

                            experiences:
                                Bindable(viewmodel).experiences,

                            onTapExperience: handleTap,

                            onVisibleExperiencesChange: { visible in

                                visibleBookExperiences = visible

                                // Mantemos a primeira experiência
                                // como experiência principal para
                                // compatibilidade com o captionView.

                                focusedExperience = visible.first

                            }

                        )
                        .transition(
                            .opacity.combined(
                                with: .scale(scale: 0.95)
                            )
                        )

                    }

                }

            }
            .frame(
                maxWidth: .infinity
            )


            // MARK: Caption

            if !viewmodel.experiences.isEmpty {

                captionView
                    .padding(
                        .top,
                        captionTopSpacing
                    )

            }

            Spacer()

            addButton
                .padding(.bottom, 30)

        }
        .background {

            Image("BackgroundMoments")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

        }
        .toolbar(
            .hidden,
            for: .navigationBar
        )
        .navigationDestination(
            isPresented: $isShowingDetail
        ) {

            if let experience =
                viewmodel.experiences.first(
                    where: {
                        $0.id == selectedExperienceID
                    }
                ) {

                ExperienceDetailScreen(
                    experience: experience
                ) { updated in

                    if let index =
                        viewmodel.experiences.firstIndex(
                            where: {
                                $0.id == updated.id
                            }
                        ) {

                        viewmodel.experiences[index] =
                            updated

                    }

                }

            }

        }
        .navigationDestination(
            isPresented:
                $isShowingAllExperiences
        ) {

            ExperiencesReadingScreen(
                experiences:
                    Bindable(viewmodel).experiences
            )

        }
        .sheet(
            isPresented:
                $isShowingAddExperience
        ) {

            AddExperienceView { newExperience in

                viewmodel.addNewExperience(
                    newExperience
                )

            }

        }
        .onAppear {

            focusedExperience =
                viewmodel.experiences.first

        }
        

    }


    // MARK: - Tap Experience

    private func handleTap(
        _ experience: Experience
    ) {

        selectedExperienceID = experience.id

        isShowingDetail = true

    }


    // MARK: - Header

    private var header: some View {

        HStack {

            Title(
                title: "Momentos",
                subtitle: ""
            )
            .foregroundStyle(.white)

            Spacer()

            if !viewmodel.experiences.isEmpty {

                Button {

                    withAnimation(
                        .easeInOut(
                            duration: 0.35
                        )
                    ) {

                        cycleDisplayMode()

                    }

                } label: {

                    Image(
                        systemName:
                            displayModeIcon
                    )
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(
                        width: 44,
                        height: 44
                    )
                    .background(
                        .ultraThinMaterial
                    )
                    .background(
                        Color.blue
                    )
                    .clipShape(
                        Circle()
                    )

                }

            }

        }
        .padding(16)

    }


    // MARK: - Cycle Display Mode

    private func cycleDisplayMode() {

        switch displayMode {

        case .stack:

            displayMode = .carousel


        case .carousel:

            displayMode = .book


        case .book:

            displayMode = .stack

        }

    }


    // MARK: - Display Icon

    private var displayModeIcon: String {

        switch displayMode {

        case .stack:

            // Próximo: Carousel
            return "rectangle.on.rectangle"


        case .carousel:

            // Próximo: Livro
            return "book.closed"


        case .book:

            // Próximo: Stack
            return "square.stack.3d.up"

        }

    }


    // MARK: - Caption Spacing

    private var captionTopSpacing: CGFloat {

        switch displayMode {

        case .stack:

            return 16

        case .carousel:

            return 16

        case .book:

            // O livro já possui uma altura maior.
            // Um espaço menor deixa o caption
            // visualmente conectado às páginas.

            return 8

        }

    }


    // MARK: - Caption

    @ViewBuilder
    private var captionView: some View {

        switch displayMode {

        // -----------------------------------
        // STACK E CAROUSEL
        // -----------------------------------

        case .stack, .carousel:

            if let experience = focusedExperience {

                caption(
                    for: experience
                )

            }


        // -----------------------------------
        // BOOK
        // -----------------------------------

        case .book:

            if visibleBookExperiences.count == 1,
               let experience =
                    visibleBookExperiences.first {

                // Apenas uma página visível.

                caption(
                    for: experience
                )

            } else if visibleBookExperiences.count >= 2 {

                // Quando existem duas páginas,
                // mostramos os títulos das duas
                // experiências abaixo do livro.

                HStack(
                    spacing: 16
                ) {

                    ForEach(
                        visibleBookExperiences,
                        id: \.id
                    ) { experience in

                        Text(
                            experience.title.isEmpty
                            ? "Sem título"
                            : experience.title
                        )
                        .font(
                            .headline
                        )
                        .foregroundStyle(
                            .white
                        )
                        .multilineTextAlignment(
                            .center
                        )
                        .lineLimit(2)
                        .frame(
                            maxWidth: .infinity
                        )

                    }

                }
                .padding(
                    .horizontal,
                    24
                )

            }

        }

    }


    // MARK: - Single Caption

    private func caption(
        for experience: Experience
    ) -> some View {

        Text(
            experience.title.isEmpty
            ? "Sem título"
            : experience.title
        )
        .font(
            .title3.bold()
        )
        .foregroundStyle(
            .white
        )
        .shadow(
            color: .black.opacity(0.2),
            radius: 2,
            x: 2,
            y: 2
        )
        .multilineTextAlignment(
            .center
        )
        .lineLimit(2)
        .padding(
            .horizontal,
            30
        )

    }


    // MARK: - Add Button

    private var addButton: some View {

        Button {

            isShowingAddExperience = true

        } label: {

            Label(
                "Adicionar experiência",
                systemImage:
                    "plus.circle.fill"
            )
            .font(
                .headline
            )
            .foregroundStyle(
                .white
            )
            .padding(8)

        }
        .buttonStyle(
            .glassProminent
        )
        .tint(
            .verdeProjeto
        )
        .padding(
            .horizontal,
            16
        )
        .padding(
            .vertical,
            30
        )

    }

}

#Preview {

    MomentosHomeView()
        .environment(
            WallieViewModel()
        )

}

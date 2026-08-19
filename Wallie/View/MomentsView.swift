//
// MomentsHomeView.swift
// Wallie
//

import SwiftUI

struct MomentsRootView: View {
    var body: some View {
        NavigationStack {
            MomentosHomeView()
        }
    }
}

struct MomentosHomeView: View {
    @Environment(WallieViewModel.self) var viewmodel

    // MARK: - Modo de exibição

    /// Adicionado `.book`, que usa a InteractiveBookView (BookView)
    /// implementada com a MomentCardFace já existente.
    enum DisplayMode {
        case stack, carousel, book
    }

    @State private var displayMode: DisplayMode = .carousel
    @State private var focusedExperience: Experience?
    @State private var isShowingAddExperience = false
    @State private var selectedExperienceID: UUID?
    @State private var isShowingDetail = false
    @State private var isShowingAllExperiences = false

    var body: some View {
        VStack {
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
                    case .stack:
                        MomentCardStack(
                            items: viewmodel.experiences,
                            onFocusChange: { focusedExperience = $0 },
                            onTapFocused: handleTap
                        )
                    case .carousel:
                        MomentCarousel(
                            items: viewmodel.experiences,
                            onFocusChange: { focusedExperience = $0 },
                            onTapFocused: handleTap
                        )
                    case .book:
                        BookView(
                            experiences: Bindable(viewmodel).experiences,
                            onTapExperience: handleTap,
                            onVisibleExperiencesChange: { visible in
                                focusedExperience = visible.first
                            }
                        )
                    }
                }
            }

            if !viewmodel.experiences.isEmpty {
                captionView.padding(.top, 16)
            }

            Spacer()

            addButton.padding(.bottom, 30)
        }
        .background {
            Image("BackgroundMoments")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingDetail) {
            if let experience = viewmodel.experiences.first(where: { $0.id == selectedExperienceID }) {
                ExperienceDetailScreen(experience: experience) { updated in
                    if let index = viewmodel.experiences.firstIndex(where: { $0.id == updated.id }) {
                        viewmodel.experiences[index] = updated
                    }
                }
            }
        }
        .navigationDestination(isPresented: $isShowingAllExperiences) {
            ExperiencesReadingScreen(experiences: Bindable(viewmodel).experiences)
        }
        .sheet(isPresented: $isShowingAddExperience) {
            AddExperienceView { newExperience in
                viewmodel.addNewExperience(newExperience)
            }
        }
    }

    private func handleTap(_ experience: Experience) {
        selectedExperienceID = experience.id
        isShowingDetail = true
    }

    private var header: some View {
        HStack {
            Title(title: "Momentos", subtitle: "")
                .foregroundStyle(.white)

            Spacer()

            if !viewmodel.experiences.isEmpty {
                Button {
                    withAnimation(.easeInOut) {
                        cycleDisplayMode()
                    }
                } label: {
                    Image(systemName: displayMode == .stack ? "book.fill" : "rectangle.fill.on.rectangle.fill")
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

    /// Avança para o próximo modo de exibição: stack -> carousel -> book -> stack.
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

    /// Ícone do botão representa o modo para o qual ele vai trocar ao ser tocado.
    private var displayModeIcon: String {
        switch displayMode {
        case .stack:
            return "rectangle.grid.1x2"
        case .carousel:
            return "book.closed"
        case .book:
            return "square.stack"
        }
    }

    @ViewBuilder
    private var captionView: some View {
        if let experience = focusedExperience {
            VStack(spacing: 6) {
                Text(experience.title.isEmpty ? "Sem título" : experience.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 60)
            }
            .padding(.horizontal, 30)
        }
    }

    private var addButton: some View {
        Button {
            isShowingAddExperience = true
        } label: {
            Label("Adicionar experiência", systemImage: "plus.circle.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(8)
        }
        .buttonStyle(.glassProminent)
        .tint(.verdeProjeto)
        .padding(.horizontal, 16)
        .padding(.vertical, 30)
    }
}

#Preview {
    MomentsRootView()
        .environment(WallieViewModel())
}

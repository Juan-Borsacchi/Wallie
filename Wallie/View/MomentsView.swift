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
    
    enum DisplayMode {
        case stack, carousel
    }
    
    @State private var displayMode: DisplayMode = .carousel
    @State private var focusedExperience: Experience?
    @State private var isShowingAddExperience = false
    @State private var selectedExperienceID: UUID?
    @State private var isShowingDetail = false
    @State private var isShowingAllExperiences = false
    
    var body: some View {
        VStack(spacing: 0) {
            header.padding(.horizontal, 20).padding(.top, 8)
            Spacer()
            
            Group {
                if viewmodel.experiences.isEmpty {
                    FirtMomentCard()
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
                        displayMode = displayMode == .stack ? .carousel : .stack
                    }
                } label: {
                    Image(systemName: displayMode == .stack ? "rectangle.grid.1x2" : "square.stack")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
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

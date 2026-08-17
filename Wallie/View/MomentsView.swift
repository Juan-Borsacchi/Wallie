import SwiftUI

struct MomentsRootView: View {
    @State private var experiences: [Experience] = []
    
    var body: some View {
        NavigationStack {
            MomentosHomeView(experiences: $experiences)
        }
    }
}

struct MomentosHomeView: View {
    @Binding var experiences: [Experience]
    
    enum DisplayMode {
        case stack, carousel
    }
    
    @State private var displayMode: DisplayMode = .carousel
    @State private var focusedExperience: Experience?
    @State private var isShowingAddExperience = false
    @State private var selectedExperienceID: UUID?
    @State private var isShowingDetail = false
    @State private var isShowingAllExperiences = false
    
    private var displayItems: [Experience] {
        experiences.isEmpty ? [Experience.placeholder] : experiences
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header.padding(.horizontal, 20).padding(.top, 8)
            Spacer()
            
            Text("Capture e veja suas experiências")
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
            
            Group {
                switch displayMode {
                case .stack:
                    MomentCardStack(
                        items: displayItems,
                        onFocusChange: { focusedExperience = $0 },
                        onTapFocused: handleTap
                    )
                case .carousel:
                    MomentCarousel(
                        items: displayItems,
                        onFocusChange: { focusedExperience = $0 },
                        onTapFocused: handleTap
                    )
                }
            }
            
            captionView.padding(.top, 16)
            Spacer()
            addButton.padding(.bottom, 30)
        }
        .background(MomentosPalette.sky.ignoresSafeArea())
        .navigationDestination(isPresented: $isShowingDetail) {
            if let experience = experiences.first(where: { $0.id == selectedExperienceID }) {
                ExperienceDetailScreen(experience: experience) { updated in
                    if let index = experiences.firstIndex(where: { $0.id == updated.id }) {
                        experiences[index] = updated
                    }
                }
            }
        }
        .navigationDestination(isPresented: $isShowingAllExperiences) {
            ExperiencesReadingScreen(experiences: $experiences)
        }
        .sheet(isPresented: $isShowingAddExperience) {
            AddExperienceView { newExperience in
                experiences.insert(newExperience, at: 0)
            }
        }
    }
    
    private func handleTap(_ experience: Experience) {
        if experience.isPlaceholder {
            isShowingAddExperience = true
        } else {
            selectedExperienceID = experience.id
            isShowingDetail = true
        }
    }
    
    private var header: some View {
        HStack {
            Text("Momentos")
                .font(.custom("Georgia", size: 30))
                .foregroundStyle(.white)
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    displayMode = displayMode == .stack ? .carousel : .stack
                }
            } label: {
                Image(systemName: displayMode == .stack ? "rectangle.grid.1x2" : "square.stack")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(.white.opacity(0.25)))
            }
        }
    }
    
    @ViewBuilder
    private var captionView: some View {
        if let experience = focusedExperience, !experience.isPlaceholder {
            VStack(spacing: 6) {
                Text(experience.title.isEmpty ? "Sem título" : experience.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 40)
                
                HStack(spacing: 12) {
                    if experience.includeDate {
                        Label(experience.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    }
                    if experience.album != "Nenhum" {
                        Label(experience.album, systemImage: "square.stack")
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                
                HStack(spacing: 16) {
                    if let quality = experience.quality {
                        Text("\(quality.emoji) \(quality.label)")
                    }
                    if let emotion = experience.emotion {
                        Text("\(emotion.emoji) \(emotion.label)")
                    }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, 30)
        }
    }
    
    private var addButton: some View {
        Button {
            isShowingAddExperience = true
        } label: {
            Label("Adicionar experiência", systemImage: "plus.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(Capsule(style: .continuous).fill(MomentosPalette.pillGradient))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    MomentsRootView()
}

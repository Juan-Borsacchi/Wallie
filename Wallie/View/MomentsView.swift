//
//  MomentsView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 21/08/26.
//

import SwiftUI

struct MomentsView: View {
    @Environment(WallieViewModel.self) var viewmodel
    
    @State private var displayMode: DisplayMode = .carousel
    @State private var focusedExperience: Experience?
    @State private var visibleBookExperiences: [Experience?] = []
    
    @State private var isShowingAddExperience = false
    @State private var selectedExperienceID: UUID?
    @State private var isShowingDetail = false
    @State private var isShowingAllExperiences = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            MomentsToolBar(
                hasExperiences: !viewmodel.recentMoments.isEmpty,
                displayModeIcon: displayModeIcon,
                onCycleMode: cycleDisplayMode
            )
            
            Spacer()
            
            MomentsMainContentView(
                viewmodel: viewmodel,
                displayMode: displayMode,
                focusedExperience: $focusedExperience,
                visibleBookExperiences: $visibleBookExperiences,
                onAddExperience: { isShowingAddExperience = true },
                onTapExperience: handleTap
            )
            ZStack{
                if !viewmodel.recentMoments.isEmpty {
                    MomentsCaption(
                        displayMode: displayMode,
                        focusedExperience: focusedExperience,
                        visibleBookExperiences: visibleBookExperiences
                    )
                    .padding(.top, captionTopSpacing)
                }
                
                
            }.padding(.top, 20)
            //            Spacer()
            
            MomentsAddButton {
                isShowingAddExperience = true
            }
            .padding(.bottom, 8)
            
        }
        .background {
            Image("BackgroundMoments")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingDetail) {
            detailDestinationView
        }
        .navigationDestination(isPresented: $isShowingAllExperiences) {
            
        }
        .sheet(isPresented: $isShowingAddExperience) {
            AddExperienceView { newExperience in
                viewmodel.addNewExperience(newExperience)
            }
        }
        .onAppear {
            focusedExperience = viewmodel.recentMoments.first
        }
    }
    
    private func handleTap(_ experience: Experience) {
        selectedExperienceID = experience.id
        isShowingDetail = true
    }
    
    private func cycleDisplayMode() {
        switch displayMode {
        case .stack:    displayMode = .carousel
        case .carousel: displayMode = .book
        case .book:     displayMode = .stack
        }
    }
    
    private var displayModeIcon: String {
        switch displayMode {
        case .stack:    return "square.2.layers.3d.fill"
        case .carousel: return "book.fill"
        case .book:     return "app.shadow"
        }
    }
    
    private var captionTopSpacing: CGFloat {
        let isSingleExperience = viewmodel.recentMoments.count == 1
        
        switch displayMode {
        case .carousel:
            return isSingleExperience ? 46 : 6
        case .stack:
            return 6
        case .book:
            return 8
        }
    }
    
    @ViewBuilder
    private var detailDestinationView: some View {
        if let experience = viewmodel.experiences.first(where: { $0.id == selectedExperienceID }) {
            XpDetailScreen(
                experience: experience,
                onSave: { updated in
                    viewmodel.updateExperience(updated)
                },
                onDelete: { deleted in
                    viewmodel.deleteExperience(deleted)
                    isShowingDetail = false
                }
            )
        }
    }
}

struct MomentsMainContentView: View {
    var viewmodel: WallieViewModel
    let displayMode: DisplayMode
    
    @Binding var focusedExperience: Experience?
    @Binding var visibleBookExperiences: [Experience?]
    
    let onAddExperience: () -> Void
    let onTapExperience: (Experience) -> Void
    
    var body: some View {
        Group {
            if viewmodel.recentMoments.isEmpty {
                MomentFirstCard()
                    .onTapGesture {
                        onAddExperience()
                    }
            } else {
                switch displayMode {
                case .stack:
                    MomentCardStack(
                        items: viewmodel.recentMoments,
                        onFocusChange: { focusedExperience = $0 },
                        onTapFocused: onTapExperience
                    )
                    
                case .carousel:
                    MomentCarousel(
                        items: viewmodel.recentMoments,
                        onFocusChange: { focusedExperience = $0 },
                        onTapFocused: onTapExperience
                    )
                    
                case .book:
                    BookView(
                        experiences: viewmodel.recentMoments,
                        onTapExperience: onTapExperience,
                        onVisibleExperiencesChange: { visible in
                            visibleBookExperiences = visible
                            focusedExperience = visible.compactMap { $0 }.first
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MomentsView()
        .environment(WallieViewModel())
}

//
//  DetailPhoto.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 18/08/26.
//

import SwiftUI

struct DetailPhotoView<Data: RandomAccessCollection, Detail: View, Overlay: View>: View where Data.Element: PhotoProtocol {
    
    @Binding var config: PhotoHeroEffectConfig<Data.Element>
    var data: Data
    @ViewBuilder var detail: (Data.Element, Bool, CGSize, @escaping () -> ()) -> Detail
    @ViewBuilder var overlay: (Data.Element?, Bool, CGSize, @escaping () -> ()) -> Overlay
    
    @State private var isExpanded: Bool = false
    @State private var viewSize: CGSize = .zero
    @State private var safeArea: EdgeInsets = .init()
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        TabView(selection: $config.selectedItem) {
            ForEach(data, id: \.id) { item in
                let sourceFrame = config.sourceLocation
                
                detail(item, isExpanded, dragOffset, dismiss)
                    .frame(
                        width: isExpanded ? viewSize.width : sourceFrame.width,
                        height: isExpanded ? viewSize.height : sourceFrame.height
                    )
                    .clipped()
                    .offset(
                        x: isExpanded ? 0 : sourceFrame.minX,
                        y: isExpanded ? 0 : sourceFrame.minY
                    )
                    .offset(dragOffset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isExpanded ? .center : .topLeading)
                    .tag(item)
                    .ignoresSafeArea()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .contentShape(.rect)
        .gesture(
            PanGesture { gesture in
                let state = gesture.state
                let translation = gesture.translation(in: gesture.view)
                
                if state == .began || state == .changed {
                    dragOffset = .init(width: translation.x, height: translation.y)
                } else {
                    if dragOffset.height > 60 {
                        dismiss()
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            dragOffset = .zero
                        }
                    }
                }
            }
        )
        .overlay {
            overlay(config.selectedItem, isExpanded, dragOffset, dismiss)
                .compositingGroup()
                .opacity(interactiveOpacity)
                .opacity(isExpanded ? 1 : 0)
        }
        .presentationBackground {
            Rectangle()
                .fill(.black)
                .opacity(interactiveOpacity)
                .opacity(isExpanded ? 1 : 0)
        }
        .allowsHitTesting(isExpanded)
        .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { viewSize = $0 })
        .onGeometryChange(for: EdgeInsets.self, of: { $0.safeAreaInsets }, action: { safeArea = $0 })
        .task {
            guard !isExpanded else { return }
            withAnimation(animation) {
                isExpanded = true
            }
        }
    }
    
    func dismiss() {
        Task {
            withAnimation(animation.speed(1.2)) {
                dragOffset = .zero
                isExpanded = false
            }
            
            try? await Task.sleep(for: .seconds(0.35))
            withoutAnimation {
                config.showFullScreenCover = false
            }
        }
    }
    
    var animation: Animation {
        .spring(response: 0.38, dampingFraction: 0.82, blendDuration: 0)
    }
    
    var interactiveOpacity: CGFloat {
        let opacityY = abs(dragOffset.height) / (viewSize.height * 0.3)
        return isExpanded ? 1 - opacityY : 0
    }
}

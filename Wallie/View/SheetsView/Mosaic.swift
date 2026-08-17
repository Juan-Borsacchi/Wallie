//
//  WallieGalleryApp.swift
//  Wallie
//
//  Created by Tais Akemi Kawaguti on 14/08/26.
//

import SwiftUI

// MARK: - 1. Protocolos e Modelos de Dados

protocol PhotoProtocol: Hashable {
    var id: String { get }
}

struct ItemGalery: Identifiable, PhotoProtocol {
    var id: String = UUID().uuidString
    var title: String
    var image: UIImage?
}

struct PinGalleryItem: Identifiable, PhotoProtocol {
    var id: String = UUID().uuidString
    var title: String
    var imageName: String
    var customHeight: CGFloat
}

// MARK: - Extensões e Dados de Amostra

extension ItemGalery {
    var calculatedHeight: CGFloat {
        guard let image = image else { return 200 }
        
        let aspectRatio = image.size.height / image.size.width
        let screenWidth = UIScreen.main.bounds.width
        
        let columnsCount: CGFloat = 2 // Número de colunas
        let spacing: CGFloat = 12     // Espaçamento entre as colunas
        let horizontalPadding: CGFloat = 15 * 2
        
        let totalSpacing = (spacing * (columnsCount - 1)) + horizontalPadding
        let dynamicColumnWidth = (screenWidth - totalSpacing) / columnsCount
        
        return dynamicColumnWidth * aspectRatio
    }
}

var sampleItems: [ItemGalery] = {
    var items: [ItemGalery] = []
    
    for i in 1...7 {
        let imageName = "foto\(i)"
        let uiImage = UIImage(named: imageName)
        
        items.append(
            ItemGalery(
                title: "Title \(i)",
                image: uiImage
            )
        )
    }
    
    return items
}()

// MARK: - 2. Componente Principal do Mosaico (PhotoMasonryGridView)

fileprivate struct PhotoHeroEffectConfig<Element: PhotoProtocol>{
    var selectedItem: Element?
    var sourceLocation: CGRect = .zero
    var sourceScrollPosition: ScrollPosition = .init()
    var showFullScreenCover: Bool = false
}

struct PhotoMasonryGridView<Data: RandomAccessCollection, GridItem: View, Detail: View, Overlay: View>: View where Data.Element: PhotoProtocol & Identifiable {

    var spacing: CGFloat = 12
    var columnsCount: Int = 2
    var data: Data
    var heightProvider: (Data.Element) -> CGFloat
    
    @ViewBuilder var gridItem: (Data.Element) -> GridItem
    @ViewBuilder var detail: (Data.Element, Bool, CGSize, @escaping () -> ()) -> Detail
    @ViewBuilder var overlay: (Data.Element?, Bool, CGSize, @escaping () -> ()) -> Overlay
    
    var onSelectionChanged: (Data.Element?) -> Void = { _ in }
    
    @State private var config: PhotoHeroEffectConfig<Data.Element> = .init()
    
    var body: some View {
        ScrollView(.vertical) {
            HStack(alignment: .top, spacing: spacing) {
                let columnsData = factoredData()
                
                ForEach(0..<columnsCount, id: \.self) { columnIndex in
                    LazyVStack(spacing: spacing) {
                        ForEach(columnsData[columnIndex]) { item in
                            Rectangle()
                                .foregroundStyle(.clear)
                                .overlay {
                                    GeometryReader { proxy in
                                        let rect = proxy.frame(in: .global)
                                        let updatedRect: CGRect? = config.selectedItem == item ? rect : nil
                                        
                                        gridItem(item)
                                            .opacity(config.selectedItem == item ? 0 : 1)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .contentShape(.rect)
                                            .onTapGesture {
                                                config.selectedItem = item
                                                config.sourceLocation = rect
                                                
                                                withoutAnimation {
                                                    config.showFullScreenCover = true
                                                }
                                            }
                                            .onChange(of: updatedRect) { _, newValue in
                                                if let newValue {
                                                    config.sourceLocation = newValue
                                                }
                                            }
                                    }
                                }
                                .frame(height: heightProvider(item))
                                .clipped()
                                .contentShape(.rect)
                        }
                    }
                }
            }
            .padding(spacing)
            .scrollTargetLayout()
        }
        .scrollPosition($config.sourceScrollPosition)
        .fullScreenCover(isPresented: $config.showFullScreenCover) {
            config.selectedItem = nil
        } content: {
            DetailPhotoView(config: $config, data: data, detail: detail, overlay: overlay)
        }
        .onChange(of: config.selectedItem) { oldValue, newValue in
            if let newValue, oldValue != nil {
                config.sourceScrollPosition.scrollTo(id: newValue.id)
            }
            onSelectionChanged(newValue)
        }
    }
    
    private func factoredData() -> [[Data.Element]] {
        var colData = Array(repeating: [Data.Element](), count: columnsCount)
        var colHeights = Array(repeating: CGFloat(0), count: columnsCount)
        
        for item in data {
            let shortestColumn = colHeights.firstIndex(of: colHeights.min()!) ?? 0
            colData[shortestColumn].append(item)
            colHeights[shortestColumn] += heightProvider(item) + spacing
        }
        
        return colData
    }
    
    func onSelectionChanged(_ perform: @escaping (Data.Element?) -> Void) -> Self {
        var copy = self
        copy.onSelectionChanged = perform
        return copy
    }
}

// MARK: - 3. DetailPhotoView (Gerenciador do Hero Effect e Gestos)

fileprivate struct DetailPhotoView<Data: RandomAccessCollection, Detail: View, Overlay: View>: View
    where Data.Element: PhotoProtocol{
    
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

// MARK: - 4. Utilitários de Gestos e Transações

fileprivate struct PanGesture: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> ()
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = context.coordinator
        return gesture
    }
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {}
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if let scrollView = otherGestureRecognizer.view as? UIScrollView {
                return scrollView.contentOffset.y == 0
            }
            return false
        }
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            let velocity = panGesture.velocity(in: panGesture.view)
            return velocity.y > abs(velocity.x)
        }
    }
}

fileprivate extension View {
    func withoutAnimation(_ result: @escaping () -> ()) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { result() }
    }
}

// MARK: - 5. Exemplo de Visualização Principal (TestView baseada no seu primeiro código)

struct TestView: View {
    var body: some View {
        NavigationStack {
            PhotoMasonryGridView(
                columnsCount: 2,
                data: sampleItems,
                heightProvider: { $0.calculatedHeight }
            ) { item in
                ImageView(item, isExpanded: false)
            } detail: { item, isExpanded, dragOffset, dismiss in
                VStack {
                    if isExpanded {
                        Spacer(minLength: 50)
                    }
                    
                    ImageView(item, isExpanded: isExpanded)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if isExpanded {
                        Spacer(minLength: 50)
                    }
                }
            } overlay: { selectedItem, isExpanded, dragOffset, dismiss in
                if #available(iOS 26.0, *) {
                    OverlayActionView(dragOffset: dragOffset, dismiss: dismiss)
                }
            }
            .onSelectionChanged { item in
                if let item {
                    print(item)
                }
            }
            .safeAreaPadding(15)
            .navigationTitle("Mosaico")
        }
    }
    
    @ViewBuilder
    func ImageView(_ item: ItemGalery, isExpanded: Bool = false) -> some View {
        Rectangle()
            .foregroundStyle(.clear)
            .overlay {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: isExpanded ? .fit : .fill)
                }
            }
            .cornerRadius(isExpanded ? 0 : 12)
            .clipped()
    }
    
    @available(iOS 26, *)
    @ViewBuilder
    func OverlayActionView(dragOffset: CGSize, dismiss: @escaping () -> ()) -> some View {
        let interactiveOpacity: CGFloat = 1 - min(abs(dragOffset.height / 30), 1)
        
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
                
                Spacer(minLength: 0)
                
                Button {
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
            }
            
            Spacer(minLength: 0)
            
            HStack {
                Button {
                } label: {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
                
                HStack(spacing: 15) {
                    Button {
                    } label: {
                        Image(systemName: "suit.heart")
                            .font(.title3)
                            .padding(10)
                    }
                    
                    Button {
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .padding(10)
                    }
                    Button {
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .padding(10)
                    }
                }
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 10)
            .glassEffect(.regular.interactive(), in: .capsule)
            .frame(maxWidth: .infinity)
            
            Button {
            } label: {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.title3)
                    .frame(width: 20, height: 30)
            }
            .buttonStyle(.glass)
        }
        .padding(15)
        .compositingGroup()
        .opacity(interactiveOpacity)
    }
}

#Preview {
    TestView()
}

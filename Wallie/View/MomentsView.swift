//
//  MomentosView.swift
//  Wallie
//
//  Created by Felipe Colares Cardoso on 17/08/26.
//

//
//  MomentosView.swift
//  Tela "Momentos" — pilha/carrossel de experiências, formulário de adicionar
//  experiência, e tela de detalhe em tela cheia.
//
//  Arquivo autocontido — não depende dos outros arquivos do projeto.
//
//  O que tem aqui:
//  - MomentosRootView: raiz com a barra de abas de baixo.
//  - MomentosHomeView: título, subtítulo, o card em destaque (pilha OU carrossel —
//    alternados pelo botão do topo) e a legenda (título + avaliação + emoções) fora
//    do card. Quando não há experiências, mostra um único card de vidro
//    ("Toque em adicionar experiência").
//  - MomentCardStack: a pilha diagonal (mesma mecânica do CardStackScroll: drag,
//    loop infinito, card "entrando por fora" ao voltar).
//  - MomentCarousel: scroll horizontal paginado com indicador de pontos.
//  - AddExperienceView: formulário com carrossel de fotos (enquadramento padrão),
//    título, descrição, data, álbum, avaliação (péssimo…excelente), emoções, e
//    barra de ferramentas (Aa, foto, emoji, cor) — áudio e desenho foram removidos.
//  - ExperienceDetailScreen: tela cheia (foto + cartão de vidro com título, tag,
//    descrição, data e emoção) — layout da terceira referência.
//  - ExperiencesReadingScreen: lista de todas as experiências, cada uma leva à
//    ExperienceDetailScreen ao tocar.
//
//  Requer iOS 17+.
//

import SwiftUI
import PhotosUI

// MARK: - Avaliação de qualidade (emoji)

enum QualityRating: String, CaseIterable, Identifiable, Codable, Hashable {
    
    case pessimo, ruim, bom, otimo, excelente
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .pessimo:   return "Péssimo"
        case .ruim:      return "Ruim"
        case .bom:       return "Bom"
        case .otimo:     return "Ótimo"
        case .excelente: return "Excelente"
        }
    }
    
    var emoji: String {
        switch self {
        case .pessimo:   return "😖"
        case .ruim:      return "🙁"
        case .bom:       return "🙂"
        case .otimo:     return "😄"
        case .excelente: return "🤩"
        }
    }
}


// MARK: - Emoção sentida

enum EmotionTag: String, CaseIterable, Identifiable, Codable, Hashable {
    
    case triste, feliz, angustiado, raiva, ansioso, calmo, surpreso, cansado
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .triste:     return "Triste"
        case .feliz:      return "Feliz"
        case .angustiado: return "Angustiado"
        case .raiva:      return "Com raiva"
        case .ansioso:    return "Ansioso"
        case .calmo:      return "Calmo"
        case .surpreso:   return "Surpreso"
        case .cansado:    return "Cansado"
        }
    }
    
    var emoji: String {
        switch self {
        case .triste:     return "😢"
        case .feliz:      return "😀"
        case .angustiado: return "😩"
        case .raiva:      return "😡"
        case .ansioso:    return "😰"
        case .calmo:      return "😌"
        case .surpreso:   return "😮"
        case .cansado:    return "🥱"
        }
    }
}


// MARK: - Modelo de uma experiência

struct Experience: Identifiable {
    
    let id: UUID
    var images: [Data]
    var title: String
    var description: String
    var includeDate: Bool
    var date: Date
    var album: String
    var quality: QualityRating?
    var emotion: EmotionTag?
    var accentColor: Color?
    var backgroundGradient: [Color]?
    var isPlaceholder: Bool
    
    init(
        id: UUID = UUID(),
        images: [Data] = [],
        title: String = "",
        description: String = "",
        includeDate: Bool = false,
        date: Date = Date(),
        album: String = "Nenhum",
        quality: QualityRating? = nil,
        emotion: EmotionTag? = nil,
        accentColor: Color? = nil,
        backgroundGradient: [Color]? = nil,
        isPlaceholder: Bool = false
    ) {
        self.id = id
        self.images = images
        self.title = title
        self.description = description
        self.includeDate = includeDate
        self.date = date
        self.album = album
        self.quality = quality
        self.emotion = emotion
        self.accentColor = accentColor
        self.backgroundGradient = backgroundGradient
        self.isPlaceholder = isPlaceholder
    }
    
    /// Card único mostrado quando ainda não existe nenhuma experiência real.
    static let placeholder = Experience(isPlaceholder: true)
}


// MARK: - Paleta usada nas telas

enum MomentosPalette {
    
    static let accentFront = Color(red: 0.30, green: 0.36, blue: 0.12)
    static let accentSoft = Color(red: 0.62, green: 0.72, blue: 0.30)
    
    static let sky = LinearGradient(
        colors: [
            Color(red: 0.30, green: 0.52, blue: 0.78),
            Color(red: 0.80, green: 0.85, blue: 0.82),
            Color(red: 0.46, green: 0.56, blue: 0.34)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let pillGradient = LinearGradient(
        colors: [accentSoft, accentFront],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let colorSwatches: [Color] = [
        .gray, .cyan, .green, .yellow, .orange, .pink, .purple, .blue
    ]
    
    static let backgroundSwatches: [[Color]] = [
        [.purple, .pink],
        [.blue, .cyan],
        [.orange, .yellow, .pink],
        [.indigo, .purple, .pink],
        [.pink.opacity(0.6), .white]
    ]
}


// MARK: - Raiz: barra de abas de baixo + conteúdo da aba selecionada

struct MomentosRootView: View {
    
    enum Tab: String, CaseIterable {
        
        case momentos, mosaico, albuns, calendario
        
        var label: String {
            switch self {
            case .momentos:   return "Momentos"
            case .mosaico:    return "Mosaico"
            case .albuns:     return "Álbuns"
            case .calendario: return "Calendário"
            }
        }
        
        var icon: String {
            switch self {
            case .momentos:   return "photo.on.rectangle.angled"
            case .mosaico:    return "square.grid.2x2"
            case .albuns:     return "square.stack"
            case .calendario: return "calendar"
            }
        }
    }
    
    @State private var selectedTab: Tab = .momentos
    @State private var experiences: [Experience] = []
    
    var body: some View {
        
        NavigationStack {
            
            ZStack(alignment: .bottom) {
                
                Group {
                    
                    switch selectedTab {
                        
                    case .momentos:
                        MomentosHomeView(experiences: $experiences)
                        
                    case .mosaico:
                        PlaceholderTabView(
                            title: "Mosaico",
                            symbol: "square.grid.2x2",
                            message: "Suas fotos vão aparecer aqui em um mosaico, assim que você adicionar experiências."
                        )
                        
                    case .albuns:
                        PlaceholderTabView(
                            title: "Álbuns",
                            symbol: "square.stack",
                            message: "Organize suas experiências em álbuns."
                        )
                        
                    case .calendario:
                        PlaceholderTabView(
                            title: "Calendário",
                            symbol: "calendar",
                            message: "Veja suas experiências organizadas por data."
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                tabBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    
    // MARK: Barra de abas (cápsula flutuante)
    
    private var tabBar: some View {
        
        HStack(spacing: 0) {
            
            ForEach(Tab.allCases, id: \.self) { tab in
                
                Button {
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                    
                } label: {
                    
                    VStack(spacing: 4) {
                        
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .medium))
                        
                        Text(tab.label)
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(
                        selectedTab == tab ? MomentosPalette.accentFront : .secondary
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .background(
            Capsule(style: .circular)
                .fill(.thickMaterial)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        )
    }
}


// MARK: - Aba "Momentos"

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
            
            header
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
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
            
            captionView
                .padding(.top, 16)
            
            /*if !experiences.isEmpty {
                
                Button("Ver todas as experiências") {
                    isShowingAllExperiences = true
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 10)
            }*/
            
            Spacer()
            
            addButton
                .padding(.bottom, 110)
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
    
    
    // MARK: Cabeçalho — o botão agora só alterna o modo de exibição
    
    private var header: some View {
        
        HStack {
            
            Text("Momentos")
                .font(.custom("Georgia", size: 30))
                .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                
                withAnimation(.easeInOut) {
                    displayMode = (displayMode == .stack) ? .carousel : .stack
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
    
    
    // MARK: Legenda fora do card — título, avaliação e emoções
    
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
                        Label(
                            experience.date.formatted(date: .abbreviated, time: .omitted),
                            systemImage: "calendar"
                        )
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


// MARK: - Cara do card (usada tanto na pilha quanto no carrossel)

struct MomentCardFace: View {

    let experience: Experience

    var body: some View {

        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.systemGray5))
            .overlay {

                if experience.isPlaceholder {

                    ZStack {

                        Rectangle().fill(.ultraThinMaterial)
                        Text("Toque em adicionar experiência")
                            .font(.subheadline.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .padding()
                    }

                } else if let data = experience.images.first, let uiImage = UIImage(data: data) {

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()

                } else {

                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                if !experience.isPlaceholder, let quality = experience.quality {
                    ratingBadge(quality)
                        .padding(10)
                }
            }
            .overlay(alignment: .topTrailing) {
                if !experience.isPlaceholder, let emotion = experience.emotion {
                    emotionBadge(emotion)
                        .padding(10)
                }
            }
    }

    private func ratingBadge(_ quality: QualityRating) -> some View {
        HStack(spacing: 5) {
            Text(quality.emoji)
            Text(quality.label)
                .lineLimit(1)
        }
        .font(.caption2.weight(.bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(.black.opacity(0.52), in: Capsule())
    }

    private func emotionBadge(_ emotion: EmotionTag) -> some View {
        HStack(spacing: 5) {
            Text(emotion.emoji)
            Text(emotion.label)
                .lineLimit(1)
        }
        .font(.caption2.weight(.bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(.black.opacity(0.52), in: Capsule())
    }
}

// MARK: - Pilha diagonal (mesma mecânica do CardStackScroll 2)

struct MomentCardStack: View {
    
    let items: [Experience]
    var cardWidth: CGFloat = 210
    var onFocusChange: (Experience) -> Void = { _ in }
    var onTapFocused: (Experience) -> Void = { _ in }
    
    @State private var focusedIndex = 0
    @State private var dragOffset: CGFloat = 0
    
    // Card que está "entrando por fora" depois de um arraste para a direita —
    // igual ao CardStackScroll: ele fica sempre por cima e usa um deslocamento
    // próprio em vez do cálculo normal de profundidade.
    @State private var incomingID: UUID?
    @State private var incomingExtraOffset: CGFloat = 0
    
    private let horizontalStep: CGFloat = 54
    private let verticalStep: CGFloat = -16
    private let scaleStep: CGFloat = 0.10
    private let maxVisible = 6
    private let cardAnimation: Animation = .spring(response: 0.45, dampingFraction: 0.82)
    
    private var cardHeight: CGFloat {
        cardWidth * 1.3
    }
    
    var body: some View {
        
        ZStack {
            
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                
                cardView(item: item, index: index)
            }
        }
        .frame(height: cardHeight + 30)
        .onChange(of: focusedIndex) { _, newValue in
            
            if items.indices.contains(newValue) {
                onFocusChange(items[newValue])
            }
        }
        .onAppear {
            
            if items.indices.contains(focusedIndex) {
                onFocusChange(items[focusedIndex])
            }
        }
    }
    
    
    private func circularDistance(from index: Int) -> Int {
        
        let count = items.count
        
        guard count > 0 else {
            return 0
        }
        
        let raw = index - focusedIndex
        
        return ((raw % count) + count) % count
    }
    
    
    @ViewBuilder
    private func cardView(item: Experience, index: Int) -> some View {
        
        let distance = circularDistance(from: index)
        let isFocused = distance == 0
        let isIncoming = item.id == incomingID
        let visible = isIncoming || distance < min(maxVisible, items.count)
        
        if visible {
            
            let depth = CGFloat(distance)
            
            let xOffset: CGFloat = {
                
                if isIncoming {
                    return incomingExtraOffset
                }
                
                if isFocused {
                    return dragOffset
                }
                
                return horizontalStep * depth
            }()
            
            let yOffset = verticalStep * depth
            
            let scale = isFocused ? 1 : 1 - (scaleStep * depth)
            
            let zIndexValue: Double =
                isIncoming
                ? Double(items.count) + 5
                : Double(items.count) - Double(distance)
            
            MomentCardFace(experience: item)
                .frame(width: cardWidth, height: cardHeight)
                .offset(x: xOffset, y: yOffset)
                .scaleEffect(scale)
                .zIndex(zIndexValue)
                .shadow(
                    color: .black.opacity(isFocused ? 0.3 : 0.18),
                    radius: isFocused ? 16 : 8,
                    x: 4,
                    y: 8
                )
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            
                            guard isFocused else {
                                return
                            }
                            
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            
                            guard isFocused else {
                                return
                            }
                            
                            handleDrag(translation: value.translation.width)
                        }
                )
                .onTapGesture {
                    
                    if isFocused {
                        
                        onTapFocused(item)
                        
                    } else {
                        
                        incomingID = nil
                        
                        withAnimation(cardAnimation) {
                            focusedIndex = index
                        }
                    }
                }
        }
    }
    
    
    private func handleDrag(translation: CGFloat) {
        
        let threshold: CGFloat = 60
        
        if translation < -threshold {
            
            withAnimation(cardAnimation) {
                nextCard()
                dragOffset = 0
            }
            
        } else if translation > threshold {
            
            goToPreviousCardFromOutside()
            
        } else {
            
            withAnimation(cardAnimation) {
                dragOffset = 0
            }
        }
    }
    
    
    private func nextCard() {
        
        guard !items.isEmpty else {
            return
        }
        
        focusedIndex = (focusedIndex + 1) % items.count
    }
    
    
    private func goToPreviousCardFromOutside() {
        
        guard !items.isEmpty else {
            return
        }
        
        let count = items.count
        let newFocusedIndex = (focusedIndex - 1 + count) % count
        let incoming = items[newFocusedIndex]
        
        incomingID = incoming.id
        incomingExtraOffset = cardWidth * 2.2
        
        withAnimation(cardAnimation) {
            
            focusedIndex = newFocusedIndex
            incomingExtraOffset = 0
            dragOffset = 0
        }
        
        let capturedID = incoming.id
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            
            if incomingID == capturedID {
                incomingID = nil
            }
        }
    }
}


// MARK: - Carrossel horizontal com dots

struct MomentCarousel: View {
    
    let items: [Experience]
    var onFocusChange: (Experience) -> Void = { _ in }
    var onTapFocused: (Experience) -> Void = { _ in }
    
    @State private var scrolledID: UUID?
    
    var body: some View {
        
        VStack(spacing: 14) {
            
            GeometryReader { geometry in
                
                let cardWidth = geometry.size.width * 0.62
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 16) {
                        
                        ForEach(items) { item in
                            
                            MomentCardFace(experience: item)
                                .frame(width: cardWidth, height: cardWidth * 1.3)
                                .id(item.id)
                                .onTapGesture {
                                    onTapFocused(item)
                                }
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, (geometry.size.width - cardWidth) / 2)
                }
                .scrollPosition(id: $scrolledID)
                .scrollTargetBehavior(.viewAligned)
            }
            .frame(height: 280)
            
            if items.count > 1 {
                
                HStack(spacing: 6) {
                    
                    ForEach(items) { item in
                        
                        Circle()
                            .fill(scrolledID == item.id ? Color.white : Color.white.opacity(0.35))
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .onChange(of: scrolledID) { _, newID in
            
            if let item = items.first(where: { $0.id == newID }) {
                onFocusChange(item)
            }
        }
        .onAppear {
            
            if scrolledID == nil {
                scrolledID = items.first?.id
            }
            
            if let first = items.first {
                onFocusChange(first)
            }
        }
    }
}


// MARK: - Tela de detalhe da experiência

struct ExperienceDetailScreen: View {

    @Environment(\.dismiss) private var dismiss

    @State var experience: Experience
    let onSave: (Experience) -> Void

    @State private var isShowingEdit = false
    @State private var selectedImageIndex = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                photoGallery

                detailContent
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .overlay(alignment: .top) {
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 8)
        }
        .sheet(isPresented: $isShowingEdit) {
            AddExperienceView(editing: experience) { updated in
                experience = updated
                onSave(updated)
            }
        }
    }

    // MARK: Galeria de fotos + dots

    private var photoGallery: some View {
        VStack(spacing: 10) {
            TabView(selection: $selectedImageIndex) {
                if experience.images.isEmpty {
                    Color(.systemGray4)
                        .frame(maxWidth: .infinity)
                        .tag(0)
                } else {
                    ForEach(Array(experience.images.enumerated()), id: \.offset) { index, data in
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .tag(index)
                        } else {
                            Color(.systemGray4)
                                .tag(index)
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 430)

            if experience.images.count > 1 {
                HStack(spacing: 6) {
                    ForEach(experience.images.indices, id: \.self) { index in
                        Circle()
                            .fill(
                                index == selectedImageIndex
                                ? Color.primary
                                : Color.secondary.opacity(0.35)
                            )
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: selectedImageIndex)
                    }
                }
            }
        }
        .background(Color(.systemGray5))
    }

    // MARK: Conteúdo abaixo das fotos

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text(experience.title.isEmpty ? "Sem título" : experience.title)
                .font(.custom("Georgia", size: 30))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !experience.description.isEmpty {
                Text(experience.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if experience.quality != nil || experience.emotion != nil {
                HStack(spacing: 12) {
                    if let quality = experience.quality {
                        detailTag(
                            title: "Como foi?",
                            value: "\(quality.emoji) \(quality.label)"
                        )
                    }

                    if let emotion = experience.emotion {
                        detailTag(
                            title: "Como se sentiu?",
                            value: "\(emotion.emoji) \(emotion.label)"
                        )
                    }
                }
            }

            Divider()

            HStack(spacing: 16) {
                if experience.includeDate {
                    Label(
                        experience.date.formatted(date: .abbreviated, time: .omitted),
                        systemImage: "calendar"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                if experience.album != "Nenhum" {
                    Label(experience.album, systemImage: "square.stack")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .padding(.bottom, 40)
    }

    private func detailTag(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: Barra superior

    private var topBar: some View {
        HStack {

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.ultraThinMaterial))
            }

            Spacer()

            Button {
                isShowingEdit = true
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.ultraThinMaterial))
            }
        }
    }
}

// MARK: - Lista de todas as experiências

struct ExperiencesReadingScreen: View {
    
    @Binding var experiences: [Experience]
    
    @State private var selectedID: UUID?
    @State private var isShowingDetail = false
    
    var body: some View {
        
        ScrollView {
            
            if experiences.isEmpty {
                
                VStack(spacing: 12) {
                    
                    Image(systemName: "book")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    
                    Text("Nenhuma experiência ainda")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
                
            } else {
                
                LazyVStack(spacing: 20) {
                    
                    ForEach(experiences) { experience in
                        
                        ExperienceCard(experience: experience)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedID = experience.id
                                isShowingDetail = true
                            }
                    }
                }
                .padding(20)
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Suas experiências")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingDetail) {
            
            if let experience = experiences.first(where: { $0.id == selectedID }) {
                
                ExperienceDetailScreen(experience: experience) { updated in
                    
                    if let index = experiences.firstIndex(where: { $0.id == updated.id }) {
                        experiences[index] = updated
                    }
                }
            }
        }
    }
}


private struct ExperienceCard: View {
    
    let experience: Experience
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            if let data = experience.images.first, let uiImage = UIImage(data: data) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(experience.title.isEmpty ? "Sem título" : experience.title)
                    .font(.headline)
                
                if !experience.description.isEmpty {
                    
                    Text(experience.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    
                    if experience.includeDate {
                        
                        Label(
                            experience.date.formatted(date: .abbreviated, time: .omitted),
                            systemImage: "calendar"
                        )
                    }
                    
                    if experience.album != "Nenhum" {
                        Label(experience.album, systemImage: "square.stack")
                    }
                    
                    if let quality = experience.quality {
                        Text(quality.emoji)
                    }
                    
                    if let emotion = experience.emotion {
                        Text(emotion.emoji)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}


// MARK: - Formulário "Adicionar experiência"

struct AddExperienceView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    let existingID: UUID?
    let onSave: (Experience) -> Void
    
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var images: [Data]
    
    @State private var title: String
    @State private var description: String
    
    @State private var includeDate: Bool
    @State private var date: Date
    
    @State private var album: String
    private let availableAlbums = ["Nenhum", "Viagem", "Família", "Trabalho"]
    
    @State private var quality: QualityRating?
    @State private var emotion: EmotionTag?
    
    @State private var accentColor: Color?
    @State private var backgroundGradient: [Color]?
    
    @State private var activeTool: ToolSheet?
    
    private enum ToolSheet: String, Identifiable {
        case textStyle, colorBackground
        var id: String { rawValue }
    }
    
    init(editing experience: Experience? = nil, onSave: @escaping (Experience) -> Void) {
        
        self.existingID = experience?.id
        self.onSave = onSave
        
        _images = State(initialValue: experience?.images ?? [])
        _title = State(initialValue: experience?.title ?? "")
        _description = State(initialValue: experience?.description ?? "")
        _includeDate = State(initialValue: experience?.includeDate ?? false)
        _date = State(initialValue: experience?.date ?? Date())
        _album = State(initialValue: experience?.album ?? "Nenhum")
        _quality = State(initialValue: experience?.quality)
        _emotion = State(initialValue: experience?.emotion)
        _accentColor = State(initialValue: experience?.accentColor)
        _backgroundGradient = State(initialValue: experience?.backgroundGradient)
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 0) {
                
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 22) {
                        
                        photoCarousel
                        
                        if images.isEmpty {
                            
                            Text("É necessário selecionar uma imagem para adicionar sua experiência.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        TextField("Dê um título para sua experiência...", text: $title)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        TextField("Escreva uma descrição", text: $description, axis: .vertical)
                            .lineLimit(3...8)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        dateRow
                        
                        albumRow
                        
                        qualityRow
                        
                        emotionRow
                        
                        toolbar
                    }
                    .padding(20)
                    .padding(.bottom, 90)
                }
                
              
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(.systemGray5)))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(existingID == nil ? "Adicionar experiência" : "Editar experiência")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    
                    Button {
                        
                        let experience = Experience(
                            id: existingID ?? UUID(),
                            images: images,
                            title: title,
                            description: description,
                            includeDate: includeDate,
                            date: date,
                            album: album,
                            quality: quality,
                            emotion: emotion,
                            accentColor: accentColor,
                            backgroundGradient: backgroundGradient
                        )
                        
                        onSave(experience)
                        dismiss()
                        
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(images.isEmpty ? Color.gray : MomentosPalette.accentSoft))
                    }
                    .disabled(images.isEmpty)
                }
            }
            .onChange(of: pickerItems) { _, newItems in
                loadImages(from: newItems)
            }
            .sheet(item: $activeTool) { tool in
                
                switch tool {
                    
                case .textStyle:
                    TextStyleSheet()
case .colorBackground:
                    ColorBackgroundPickerSheet(
                        accentColor: $accentColor,
                        backgroundGradient: $backgroundGradient
                    )
                }
            }
        }
    }
    
    
    // MARK: Carrossel de fotos (a primeira é a capa) — enquadramento padrão
    
    private var photoCarousel: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 12) {
                
                ForEach(Array(images.enumerated()), id: \.offset) { index, data in
                    
                    if let uiImage = UIImage(data: data) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(alignment: .topLeading) {
                                
                                if index == 0 {
                                    
                                    Text("Capa")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(.black.opacity(0.5)))
                                        .padding(6)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                
                                Button {
                                    images.remove(at: index)
                                } label: {
                                    
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                        .padding(6)
                                }
                            }
                    }
                }
                
                PhotosPicker(selection: $pickerItems, maxSelectionCount: 6, matching: .images) {
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black)
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        )
                }
            }
            .padding(.horizontal, 2)
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        
        Task {
            
            var loaded: [Data] = []
            
            for item in items {
                
                if let data = try? await item.loadTransferable(type: Data.self) {
                    loaded.append(data)
                }
            }
            
            images.append(contentsOf: loaded)
            pickerItems = []
        }
    }
    
    
    // MARK: Linha "Data"
    
    private var dateRow: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                
                Text("Data")
                
                Spacer()
                
                Toggle("", isOn: $includeDate.animation())
                    .labelsHidden()
            }
            .padding(14)
            
            if includeDate {
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            }
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    
    // MARK: Linha "Mover para álbum"
    
    private var albumRow: some View {
        
        Menu {
            
            ForEach(availableAlbums, id: \.self) { option in
                
                Button(option) {
                    album = option
                }
            }
            
        } label: {
            
            HStack {
                
                Image(systemName: "archivebox")
                    .foregroundStyle(.secondary)
                
                Text("Mover para álbum")
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(album)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
    
    
    // MARK: Campo "Como foi?"

    private var qualityRow: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Como foi?")
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 8) {
                ForEach(QualityRating.allCases) { rating in
                    Button {
                        quality = (quality == rating) ? nil : rating
                    } label: {
                        VStack(spacing: 5) {
                            Text(rating.emoji)
                                .font(.title3)

                            Text(rating.label)
                                .font(.caption2.weight(.medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    quality == rating
                                    ? Color.accentColor.opacity(0.18)
                                    : Color(.systemGray6)
                                )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    quality == rating
                                    ? Color.accentColor.opacity(0.65)
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        }
                        .foregroundStyle(
                            quality == rating ? Color.accentColor : .primary
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Campo "Como se sentiu?"

    private var emotionRow: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Como se sentiu?")
                .font(.subheadline.weight(.semibold))

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: 10
            ) {

                ForEach(EmotionTag.allCases) { tag in

                    Button {
                        emotion = (emotion == tag) ? nil : tag
                    } label: {

                        VStack(spacing: 4) {
                            Text(tag.emoji)
                                .font(.title3)

                            Text(tag.label)
                                .font(.caption2.weight(.medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            if emotion == tag {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                            }
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    emotion == tag
                                    ? Color.accentColor.opacity(0.18)
                                    : Color(.systemGray6)
                                )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    emotion == tag
                                    ? Color.accentColor.opacity(0.65)
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        }
                        .foregroundStyle(
                            emotion == tag ? Color.accentColor : .primary
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Barra de ferramentas de baixo (áudio e desenho removidos)
    
    private var toolbar: some View {
        
        HStack(spacing: 0) {
            
            toolButton(symbol: "textformat") {
                activeTool = .textStyle
            }
            
            ZStack {
                
                toolButton(symbol: "photo.on.rectangle") {}
                
                PhotosPicker(selection: $pickerItems, maxSelectionCount: 6, matching: .images) {
                    Color.clear
                }
            }
toolButton(symbol: "paintpalette") {
                activeTool = .colorBackground
            }
        }
        .padding(.vertical, 10)
        .background(.thickMaterial)
    }
    
    private func toolButton(symbol: String, action: @escaping () -> Void) -> some View {
        
        Button(action: action) {
            
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Ferramenta: estilo de texto

private struct TextStyleSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var selected = "Padrão"
    private let options = ["Padrão", "Serifada", "Arredondada", "Monoespaçada"]
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            Capsule().fill(Color(.systemGray4)).frame(width: 40, height: 5).padding(.top, 8)
            
            Text("Estilo de texto")
                .font(.headline)
            
            ForEach(options, id: \.self) { option in
                
                Button {
                    selected = option
                    dismiss()
                } label: {
                    
                    HStack {
                        Text(option)
                        Spacer()
                        if option == selected {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .presentationDetents([.height(300)])
    }
}


// MARK: - Ferramenta: cor e plano de fundo

private struct ColorBackgroundPickerSheet: View {
    
    @Binding var accentColor: Color?
    @Binding var backgroundGradient: [Color]?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 18) {
            
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            
            Text("Cor")
                .font(.headline)
                .padding(.horizontal, 20)
            
            HStack(spacing: 14) {
                
                ForEach(MomentosPalette.colorSwatches, id: \.self) { color in
                    
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay {
                            
                            if accentColor == color {
                                Circle().stroke(.primary, lineWidth: 2).padding(-3)
                            }
                        }
                        .onTapGesture {
                            accentColor = color
                        }
                }
            }
            .padding(.horizontal, 20)
            
            Text("Plano de fundo")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.top, 6)
            
            HStack(spacing: 14) {
                
                ForEach(Array(MomentosPalette.backgroundSwatches.enumerated()), id: \.offset) { _, gradientColors in
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay {
                            
                            if backgroundGradient == gradientColors {
                                Circle().stroke(.primary, lineWidth: 2).padding(-3)
                            }
                        }
                        .onTapGesture {
                            backgroundGradient = gradientColors
                        }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .presentationDetents([.height(320)])
    }
}


// MARK: - Placeholder simples para as outras abas

struct PlaceholderTabView: View {
    
    let title: String
    let symbol: String
    let message: String
    
    var body: some View {
        
        VStack(spacing: 14) {
            
            Spacer()
            
            Image(systemName: symbol)
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.title2.bold())
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}


// MARK: - Preview

#Preview {
    MomentosRootView()
}


// MARK: - Ponto de Entrada do App (Entry Point)

//@main
struct MomentosApp: App {
    var body: some Scene {
        WindowGroup {
            MomentosRootView()
        }
    }
}

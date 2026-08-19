//
//  AddExperienceView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddExperienceView: View {

    @Environment(\.dismiss) private var dismiss

    let existingID: UUID?
    let onSave: (Experience) -> Void

    // MARK: - Dados principais

    @State private var coverImage: UIImage?
    @State private var title: String
    @State private var description: String
    @State private var includeDate: Bool
    @State private var date: Date
    @State private var album: String
    @FocusState private var isInputFocused: Bool

    // MARK: - Itens extras

    @State private var itensExtras: [AddItem]

    // MARK: - Galeria da capa

    @State private var showCoverPhotoPicker = false
    @State private var selectedCoverPhotoItems: [PhotosPickerItem] = []

    // MARK: - Câmera da capa

    @State private var showCoverCamera = false
    @State private var capturedCoverImage: UIImage?

    // MARK: - Galeria da toolbar

    @State private var showPhotoPicker = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    // MARK: - Câmera da toolbar

    @State private var showCamera = false
    @State private var capturedCameraImage: UIImage?

    // MARK: - Barra inferior

    @State private var mostrarBarraDeItens = false

    // MARK: - Aparência

    @State private var accentColor: Color?
    @State private var backgroundGradient: [Color]?

    private let availableAlbums = [
        "Nenhum",
        "Viagem",
        "Família",
        "Trabalho"
    ]

    // MARK: - Inicialização

    init(
        editing experience: Experience? = nil,
        onSave: @escaping (Experience) -> Void
    ) {
        self.existingID = experience?.id
        self.onSave = onSave

        _title = State(
            initialValue: experience?.title ?? ""
        )

        _description = State(
            initialValue: experience?.description ?? ""
        )

        _includeDate = State(
            initialValue: experience?.includeDate ?? false
        )

        _date = State(
            initialValue: experience?.date ?? Date()
        )

        _album = State(
            initialValue: experience?.album ?? "Nenhum"
        )

        _accentColor = State(
            initialValue: experience?.accentColor
        )

        _backgroundGradient = State(
            initialValue: experience?.backgroundGradient
        )

        // Recupera a capa existente se houver
        if let data = experience?.images.first,
           let image = UIImage(data: data) {
            _coverImage = State(initialValue: image)
        } else {
            _coverImage = State(initialValue: nil)
        }

        // Recupera os itens extras
        _itensExtras = State(
            initialValue: experience?.extraItems ?? []
        )
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollViewReader { proxy in

                ScrollView {

                    VStack(spacing: 0) {

                        // MARK: Capa (Só exibe a foto quando houver uma selecionada)

                        coverSection
                            .id("top")

                        // MARK: Formulário Principal

                        mainForm

                        Divider()
                            .padding(.top, 8)

                        // MARK: Itens extras

                        DynamicItemsSection(
                            itens: $itensExtras
                        )
                        .padding(.top, 8)

                        Spacer(minLength: 110)
                    }

                    .onChange(of: itensExtras.count) { _, _ in

                        guard let ultimoItem = itensExtras.last else {
                            return
                        }

                        withAnimation(.easeOut(duration: 0.3)) {

                            proxy.scrollTo(
                                ultimoItem.id,
                                anchor: .bottom
                            )
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }

            // MARK: Toolbar

            .toolbar {

                // Botão cancelar

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button {

                        dismiss()

                    } label: {

                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                    }
                }

                // Título da barra

                ToolbarItem(
                    placement: .principal
                ) {

                    Text(
                        existingID == nil
                        ? "Adicionar experiência"
                        : "Editar experiência"
                    )
                    .font(.headline)
                }

                // Botão Salvar

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button {

                        salvarExperiencia()

                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.verdeProjeto)
                }

                // MARK: Toolbar inferior

                if mostrarBarraDeItens {

                    ToolbarItem(
                        placement: .bottomBar
                    ) {

                        HStack(spacing: 24) {

                            ForEach(
                                AddListModel.allCases
                            ) { tipo in

                                botaoAdicao(tipo)
                            }
                        }
                        .padding(.horizontal)
                    }

                } else {

                    ToolbarItem(
                        placement: .bottomBar
                    ) {

                        Spacer()
                    }

                    ToolbarItem(
                        placement: .bottomBar
                    ) {

                        Button {

                            withAnimation(
                                .easeInOut(duration: 0.2)
                            ) {

                                mostrarBarraDeItens = true
                            }

                        } label: {

                            Image(systemName: "plus")
                        }
                    }
                }
            }

            // MARK: - PhotosPicker da capa

            .photosPicker(
                isPresented: $showCoverPhotoPicker,
                selection: $selectedCoverPhotoItems,
                maxSelectionCount: 1,
                matching: .images
            )

            // MARK: - Camera da capa

            .sheet(
                isPresented: $showCoverCamera
            ) {

                CameraPickerView(
                    selectedImage: $capturedCoverImage
                )
                .ignoresSafeArea()
            }

            // MARK: - PhotosPicker da toolbar

            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItems,
                maxSelectionCount: 10,
                matching: .images
            )

            // MARK: - Camera da toolbar

            .sheet(
                isPresented: $showCamera
            ) {

                CameraPickerView(
                    selectedImage: $capturedCameraImage
                )
                .ignoresSafeArea()
            }

            // MARK: - Foto escolhida para capa

            .onChange(
                of: selectedCoverPhotoItems
            ) { _, newItems in

                guard !newItems.isEmpty else {
                    return
                }

                carregarCapa(
                    newItems
                )
            }

            // MARK: - Foto tirada para capa

            .onChange(
                of: capturedCoverImage
            ) { _, newImage in

                guard let image = newImage else {
                    return
                }

                withAnimation(
                    .easeInOut(duration: 0.25)
                ) {

                    coverImage = image
                }

                capturedCoverImage = nil
            }

            // MARK: - Fotos escolhidas na toolbar

            .onChange(
                of: selectedPhotoItems
            ) { _, newItems in

                guard !newItems.isEmpty else {
                    return
                }

                carregarFotosDosItens(
                    newItems
                )
            }

            // MARK: - Foto tirada na toolbar

            .onChange(
                of: capturedCameraImage
            ) { _, newImage in

                guard let image = newImage else {
                    return
                }

                withAnimation {

                    itensExtras.append(
                        AddItem(
                            type: .camera,
                            content: .images([image])
                        )
                    )
                }

                capturedCameraImage = nil
            }
        }
    }

    // MARK: - Capa

    private var coverSection: some View {
        VStack(spacing: 14) {
            // Exibe a foto da capa somente quando uma imagem for inserida
            if let image = coverImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 220,
                            maxHeight: 320
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 24,
                                style: .continuous
                            )
                        )
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: 24,
                                style: .continuous
                            )
                            .stroke(
                                Color.black.opacity(0.08),
                                lineWidth: 1
                            )
                        }

                    Button {
                        withAnimation {
                            coverImage = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                .white,
                                .black.opacity(0.55)
                            )
                            .padding(10)
                    }
                }
            }

            // Botões de escolha que aparecem sempre
            HStack(spacing: 12) {
                coverGalleryButton(
                    title: coverImage == nil ? "Acessar Galeria" : "Trocar foto",
                    icon: "photo"
                )

                Button {
                    showCoverCamera = true
                } label: {
                    Label(
                        coverImage == nil ? "Tirar foto" : "Tirar outra",
                        systemImage: coverImage == nil ? "camera.fill" : "camera"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(coverImage == nil ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        coverImage == nil ? MomentosPalette.accentSoft : Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    // MARK: - Botão da galeria da capa

    private func coverGalleryButton(
        title: String,
        icon: String
    ) -> some View {

        Button {

            showCoverPhotoPicker = true

        } label: {

            Label(
                title,
                systemImage: icon
            )
            .font(
                .subheadline.weight(.semibold)
            )
            .foregroundStyle(.primary)
            .frame(
                maxWidth: .infinity
            )
            .padding(
                .vertical,
                12
            )
            .background(
                Color(.secondarySystemBackground),
                in: RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Formulário

    private var mainForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Campo de Título com Rótulo
            VStack(alignment: .leading, spacing: 6) {
                Text("Título")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                TextField("Dê um título para sua experiência...", text: $title)
                    .focused($isInputFocused)
                    .padding(14)
                    .background(
                        Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
            }

            // Campo de Descrição com Rótulo
            VStack(alignment: .leading, spacing: 6) {
                Text("Descrição")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                TextField("Escreva uma descrição...", text: $description, axis: .vertical)
                    .focused($isInputFocused)
                    .lineLimit(3...8)
                    .padding(14)
                    .background(
                        Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
            }

            dateRow
            albumRow
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    isInputFocused = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Data

    private var dateRow: some View {

        VStack(spacing: 0) {

            HStack {

                Image(
                    systemName: "calendar"
                )
                .foregroundStyle(.secondary)

                Text("Data")

                Spacer()

                Toggle(
                    "",
                    isOn: $includeDate.animation()
                )
                .labelsHidden()
            }
            .padding(14)

            if includeDate {

                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
        )
    }

    // MARK: - Álbum

    private var albumRow: some View {

        Menu {

            ForEach(
                availableAlbums,
                id: \.self
            ) { option in

                Button {

                    album = option

                } label: {

                    HStack {

                        Text(option)

                        if option == album {

                            Image(
                                systemName: "checkmark"
                            )
                        }
                    }
                }
            }

        } label: {

            HStack {

                Image(
                    systemName: "archivebox"
                )
                .foregroundStyle(.secondary)

                Text("Mover para álbum")

                Spacer()

                Text(album)
                    .foregroundStyle(.secondary)

                Image(
                    systemName:
                        "chevron.up.chevron.down"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(
                Color(.secondarySystemBackground),
                in: RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )
        }
        .foregroundStyle(.primary)
    }

    // MARK: - Botões da toolbar

    @ViewBuilder
    private func botaoAdicao(
        _ tipo: AddListModel
    ) -> some View {

        Button {

            switch tipo {

            case .mood:

                adicionarItem(.mood)

            case .photo:

                showPhotoPicker = true

            case .camera:

                showCamera = true

            case .audio:

                adicionarItem(.audio)
            }

        } label: {

            Image(
                systemName: tipo.icon
            )
        }
    }

    // MARK: - Adicionar item

    private func adicionarItem(
        _ tipo: AddListModel
    ) {

        withAnimation {

            switch tipo {

            case .mood:

                itensExtras.append(
                    AddItem(
                        type: .mood,
                        content: .mood(
                            quality: nil,
                            emotion: nil
                        )
                    )
                )

            case .photo:

                itensExtras.append(
                    AddItem(
                        type: .photo
                    )
                )

            case .camera:

                itensExtras.append(
                    AddItem(
                        type: .camera
                    )
                )

            case .audio:

                itensExtras.append(
                    AddItem(
                        type: .audio
                    )
                )
            }
        }
    }

    // MARK: - Carregar fotos da toolbar

    private func carregarFotosDosItens(
        _ items: [PhotosPickerItem]
    ) {

        Task {

            var loadedImages: [UIImage] = []

            for item in items {

                if let data = try? await item.loadTransferable(
                    type: Data.self
                ),
                let image = UIImage(data: data) {

                    loadedImages.append(image)
                }
            }

            await MainActor.run {

                if !loadedImages.isEmpty {

                    withAnimation {

                        itensExtras.append(
                            AddItem(
                                type: .photo,
                                content: .images(
                                    loadedImages
                                )
                            )
                        )
                    }
                }

                selectedPhotoItems.removeAll()
            }
        }
    }

    // MARK: - Carregar capa

    private func carregarCapa(
        _ items: [PhotosPickerItem]
    ) {

        guard let item = items.first else {
            return
        }

        Task {

            if let data = try? await item.loadTransferable(
                type: Data.self
            ),
            let image = UIImage(data: data) {

                await MainActor.run {

                    withAnimation(
                        .easeInOut(duration: 0.25)
                    ) {

                        coverImage = image
                    }

                    selectedCoverPhotoItems.removeAll()
                }
            }
        }
    }

    // MARK: - Salvar

    private func salvarExperiencia() {

        var imagesData: [Data] = []

        if let coverImage,
           let coverData = coverImage.jpegData(compressionQuality: 0.9) {
            imagesData.append(coverData)
        }

        var quality: QualityRating?
        var emotion: EmotionTag?

        for item in itensExtras {

            if case let .mood(
                itemQuality,
                itemEmotion
            ) = item.content {

                quality = itemQuality
                emotion = itemEmotion

                if quality != nil ||
                    emotion != nil {

                    break
                }
            }
        }

        let experience = Experience(

            id: existingID ?? UUID(),

            images: imagesData,

            title: title,

            description: description,

            includeDate: includeDate,

            date: date,

            album: album,

            quality: quality,

            emotion: emotion,

            accentColor: accentColor,

            backgroundGradient: backgroundGradient,

            isPlaceholder: false,

            extraItems: itensExtras
        )

        onSave(experience)

        dismiss()
    }
}

// MARK: - Preview

#Preview {

    AddExperienceView { experience in

        print(
            "Experiência salva: \(experience.title)"
        )
    }
}

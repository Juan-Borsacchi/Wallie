//
//  AddExperienceView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI
import PhotosUI

struct AddExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddExperienceViewModel
    @FocusState private var isInputFocused: Bool
    
    @State private var isShowingCreateAlbum = false
    
    init(
        editing experience: Experience? = nil,
        availableAlbums: [String] = [],
        onSave: @escaping (Experience) -> Void
    ) {
        _viewModel = State(initialValue: AddExperienceViewModel(
            editing: experience,
            availableAlbums: availableAlbums,
            onSave: onSave
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ExperienceCoverHeaderView(
                            coverImage: $viewModel.coverImage,
                            onSelectPhoto: { viewModel.showCoverPhotoPicker = true },
                            onTakePhoto: { viewModel.activeSheet = .coverCamera }
                        )
                        .id("top")
                        
                        mainForm
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        DynamicItemsSection(itens: $viewModel.itensExtras)
                        
                        Spacer(minLength: 110)
                    }
                    .padding(.top, 12)
                    .onChange(of: viewModel.itensExtras.count) { _, _ in
                        guard let ultimoItem = viewModel.itensExtras.last else { return }
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(ultimoItem.id, anchor: .bottom)
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .background(Color(.secondarySystemBackground))
            }
            .toolbar { toolbarContent }
            .photosPicker(
                isPresented: $viewModel.showCoverPhotoPicker,
                selection: $viewModel.selectedCoverPhotoItems,
                maxSelectionCount: 1,
                matching: .images
            )
            .photosPicker(
                isPresented: $viewModel.showPhotoPicker,
                selection: $viewModel.selectedPhotoItems,
                maxSelectionCount: 10,
                matching: .images
            )
            .sheet(item: $viewModel.activeSheet) { sheetType in
                switch sheetType {
                case .coverCamera:
                    CameraPickerView(selectedImage: $viewModel.capturedCoverImage)
                        .ignoresSafeArea()
                    
                case .extraCamera:
                    CameraPickerView(selectedImage: $viewModel.capturedCameraImage)
                        .ignoresSafeArea()
                    
                case .createAlbum:
                    CreateAlbumView(
                        existingAlbums: viewModel.availableAlbums.map { formAlbum(name: $0) }
                    ) { novoAlbum in
                        viewModel.availableAlbums.append(novoAlbum.name)
                        viewModel.album = novoAlbum.name
                    }
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
                }
            }
        }
    }
    
    private var mainForm: some View {
        VStack(spacing: 14) {
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Título", systemImage: "text.cursor")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    TextField("Dê um título para sua experiência...", text: $viewModel.title)
                        .focused($isInputFocused)
                }
                .padding(14)
                .background(
                    Color(.systemBackground),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                
                Text("Campo obrigatório.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Descrição", systemImage: "text.justify.left")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                TextField("Escreva uma descrição...", text: $viewModel.description, axis: .vertical)
                    .focused($isInputFocused)
                    .lineLimit(3...8)
            }
            .padding(14)
            .background(
                Color(.systemBackground),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            
            Divider()
            
            DateSelectionRow(
                includeDate: $viewModel.includeDate,
                date: $viewModel.date
            )
            
            AlbumSelectionMenu(
                album: $viewModel.album,
                availableAlbums: viewModel.availableAlbums,
                onCreateNewAlbum: { viewModel.activeSheet = .createAlbum }
            )
        }
        .padding(.horizontal, 16)
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
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.primary)
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(viewModel.existingID == nil ? "Adicionar experiência" : "Editar experiência")
                .font(.headline)
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                viewModel.salvarExperiencia()
                dismiss()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.borderedProminent)
            .tint(.verdeProjeto)
            .disabled(viewModel.isSaveDisabled)
        }
        
        ToolbarItem(placement: .bottomBar) {
            HStack(spacing: 24) {
                ForEach(AddListModel.allCases) { tipo in
                    Button {
                        viewModel.adicionarItem(tipo)
                    } label: {
                        Image(systemName: tipo.icon)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    AddExperienceView(availableAlbums: ["Viagem", "Família"]) { experience in
        print(experience.title)
    }
}

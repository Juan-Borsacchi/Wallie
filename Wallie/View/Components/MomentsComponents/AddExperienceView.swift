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
    @StateObject private var viewModel: AddExperienceViewModel
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Inicializador Atualizado
    init(
        editing experience: Experience? = nil,
        availableAlbums: [String] = [],
        onSave: @escaping (Experience) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: AddExperienceViewModel(
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
                        
                        // MARK: - Capa
                        ExperienceCoverHeaderView(
                            coverImage: $viewModel.coverImage,
                            onSelectPhoto: { viewModel.showCoverPhotoPicker = true },
                            onTakePhoto: { viewModel.showCoverCamera = true }
                        )
                        .id("top")
                        
                        // MARK: - Formulário Principal
                        mainForm
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // MARK: - Itens Extras
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
            .sheet(isPresented: $viewModel.showCoverCamera) {
                CameraPickerView(selectedImage: $viewModel.capturedCoverImage)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $viewModel.showCamera) {
                CameraPickerView(selectedImage: $viewModel.capturedCameraImage)
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Formulário
    private var mainForm: some View {
        VStack(spacing: 14) {
            
            // MARK: Seção Título (Card + Legenda externa)
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
                
                // Texto informativo fora da área do card
                Text("Campo obrigatório.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 12)
            }
            
            // MARK: Seção Descrição
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
            
            // Seletor de Data
            DateSelectionRow(
                includeDate: $viewModel.includeDate,
                date: $viewModel.date
            )
            
            // Seletor de Álbum
            AlbumSelectionMenu(
                album: $viewModel.album,
                availableAlbums: viewModel.availableAlbums
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
    
    // MARK: - Toolbar Content
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
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AddExperienceView(availableAlbums: ["Viagem", "Família"]) { experience in
        print("Experiência salva: \(experience.title)")
    }
}

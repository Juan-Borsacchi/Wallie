//
//  CreateMomentView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI
import PhotosUI

struct CreateMomentView: View {

    @Environment(\.dismiss) var dismiss

    @State private var newTitle: String = ""
    @State private var description: String = ""
    @State private var includeDate: Bool = false
    @State private var momentData: Date = Date()
    @State private var moveToAlbum: String = ""

    @State private var selectedImage: UIImage? = nil

    @State private var itensExtras: [AddItem] = []
    @State private var mostrarBarraDeItens = false
    
    // Controles para Galeria
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    
    // Controles para Câmera
    @State private var showCamera = false
    @State private var capturedCameraImage: UIImage? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    ViewCameraGalery(imagemFinal: $selectedImage)
                        .frame(height: selectedImage == nil ? 180 : 380)
                        .padding(.top)

                    CreateMomentForm(
                        newTitle: $newTitle,
                        description: $description,
                        includeDate: $includeDate,
                        momentData: $momentData,
                        moveToAlbum: $moveToAlbum
                    )

                    DynamicItemsSection(itens: $itensExtras)
                        .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolBarCreateMoment(
                    cancelAction: {
                        dismiss()
                    },
                    confirmAction: {
                        dismiss()
                    }
                )

                if mostrarBarraDeItens {
                    ToolbarItem(placement: .bottomBar) {
                        HStack(spacing: 24) {
                            ForEach(AddListModel.allCases) { tipo in
                                botaoAdicao(tipo)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }

                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                mostrarBarraDeItens = true
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            // Seletor de Galeria Nativo
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItems,
                maxSelectionCount: 10,
                matching: .images
            )
            // Câmera usando o SEU CameraPickerView
            .sheet(isPresented: $showCamera) {
                CameraPickerView(selectedImage: $capturedCameraImage)
                    .ignoresSafeArea()
            }
            // Processa seleção de fotos da Galeria
            .onChange(of: selectedPhotoItems) { _, newItems in
                guard !newItems.isEmpty else { return }
                
                Task {
                    var loadedImages: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            loadedImages.append(image)
                        }
                    }
                    
                    await MainActor.run {
                        if !loadedImages.isEmpty {
                            withAnimation {
                                itensExtras.append(AddItem(type: .photo, content: .images(loadedImages)))
                            }
                        }
                        selectedPhotoItems.removeAll()
                    }
                }
            }
            // Processa a imagem capturada pela Câmera
            .onChange(of: capturedCameraImage) { _, newImage in
                guard let image = newImage else { return }
                withAnimation {
                    itensExtras.append(AddItem(type: .camera, content: .images([image])))
                }
                capturedCameraImage = nil
            }
        }
    }

    @ViewBuilder
    private func botaoAdicao(_ tipo: AddListModel) -> some View {
        Button {
            switch tipo {
            case .photo:
                showPhotoPicker = true
            case .camera:
                showCamera = true // Abre o seu CameraPickerView imediatamente
            default:
                adicionarItem(tipo)
            }
        } label: {
            Image(systemName: tipo.icon)
        }
    }

    private func adicionarItem(_ tipo: AddListModel) {
        withAnimation {
            itensExtras.append(AddItem(type: tipo))
        }
    }
}

#Preview {
    CreateMomentView()
}

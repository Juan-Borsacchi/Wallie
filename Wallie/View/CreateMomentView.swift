//
//  CreateMomentView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI
 
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
        }
    }
 

    @ViewBuilder
    private func botaoAdicao(_ tipo: AddListModel) -> some View {
        Button {
            adicionarItem(tipo)
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
 

//
//  CameraAndGalery.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct ViewCameraGalery: View {
    @StateObject private var photoManager = PhotoManager()
    @State private var showCamera = false
    
    @State private var idFotoSelecionada: String? = nil
    @Binding var imagemFinal: UIImage?
    
    var body: some View {
        VStack {
            //Preview da imagem selecionada
            if let imagemFinal {
                Image(uiImage: imagemFinal)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    //Botao da camera (Camera.swift)
                    PickerPhotoCamera()
                        .onTapGesture {
                            showCamera = true
                        }
                    
                    //Fotos recentes da galeria
                    ForEach(photoManager.recentImages) { itemFoto in
                        
                        //(Galery.swift)
                        PickerPhotoGalery(
                            fotoRecebida: itemFoto.image,
                            isSelected: idFotoSelecionada == itemFoto.id
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if idFotoSelecionada == itemFoto.id {
                                    idFotoSelecionada = nil
                                    imagemFinal = nil
                                } else {
                                    idFotoSelecionada = itemFoto.id
                                    imagemFinal = itemFoto.image
                                }
                            }
                        }
                    }
                    
                    //Caso a galeria esteja vazia
                    if photoManager.recentImages.isEmpty {
                        ForEach(0..<3, id: \.self) { index in
                            let idSkineve = "skineve_\(index)"
                            
                            PickerPhotoGalery(
                                fotoRecebida: nil,
                                isSelected: idFotoSelecionada == idSkineve
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if idFotoSelecionada == idSkineve {
                                        idFotoSelecionada = nil
                                        imagemFinal = nil
                                    } else {
                                        idFotoSelecionada = idSkineve
                                        if let imagemMock = UIImage(named: "skineve") {
                                            imagemFinal = imagemMock
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            photoManager.requestPermissionAndFetch()
        }
        .fullScreenCover(isPresented: $showCamera) {
            //(CameraPickerView.swift)
            CameraPickerView(selectedImage: $imagemFinal)
                .ignoresSafeArea()
                .onDisappear {
                    if imagemFinal != nil {
                        idFotoSelecionada = nil
                    }
                }
        }
    }
}

#Preview {
    ViewCameraGalery(imagemFinal: .constant(nil))
}

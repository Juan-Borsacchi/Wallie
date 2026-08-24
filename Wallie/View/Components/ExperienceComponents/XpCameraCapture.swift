//
//  XpCameraCapture.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 18/08/26.
//

import SwiftUI

struct XpCameraCapture: View {
    @Binding var image: UIImage?
    @State private var mostrarCamera = false
    
    private var cameraDisponivel: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var body: some View {
        Button {
            mostrarCamera = true
        } label: {
            conteudo
        }
        .buttonStyle(.plain)
        .disabled(!cameraDisponivel)
        .sheet(isPresented: $mostrarCamera) {
            CameraPicker(image: $image)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var conteudo: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 100)
                .overlay {
                    Label(
                        cameraDisponivel ? "Tirar foto" : "Câmera indisponível",
                        systemImage: "camera"
                    )
                    .foregroundStyle(.secondary)
                }
        }
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

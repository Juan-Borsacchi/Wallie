//
//  Camera.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct PickerPhotoCamera: View {
    var body: some View {
        VStack {
            Image(systemName: "camera")
            Text("Tire uma foto")
                .font(.caption)
        }
        .frame(width: 92, height: 140)
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PickerPhotoGalery: View {
    var fotoRecebida: UIImage? = nil
    var isSelected: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            if let fotoRecebida = fotoRecebida {
                Image(uiImage: fotoRecebida)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 92, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image("skineve")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 92, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 4)
                .frame(width: 92, height: 140)
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .background(Circle().fill(Color.white))
                    .padding(6)
            }
        }
    }
}

#Preview {
    PickerPhotoGalery(isSelected: true)
}

#Preview {
    PickerPhotoCamera()
}


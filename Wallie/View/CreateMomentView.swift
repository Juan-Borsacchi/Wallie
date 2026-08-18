//
//  CreateMomentView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct CreateMomentView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext

    
    @State private var newTitle: String = ""
    @State private var description: String = ""
    @State private var includeDate: Bool = false
    @State private var momentData: Date = Date()
    @State private var moveToAlbum: String = ""
    
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            
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
            }
        }
    }
}

#Preview {
    CreateMomentView()
}

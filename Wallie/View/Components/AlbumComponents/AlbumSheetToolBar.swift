//
//  AlbumSheetToolBar.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct AlbumSheetToolBar: ToolbarContent {
    var cancelAction: () -> Void
    var confirmAction: () -> Void
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: .cancellationAction) {
            Button(action: cancelAction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text("Criar Album")
                .font(.headline)
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button(action: confirmAction) {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
            .tint(.verdeProjeto)
        }
        
    }
}

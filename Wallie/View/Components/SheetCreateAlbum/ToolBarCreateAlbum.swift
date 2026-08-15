//
//  ToolBarCreateAlbum.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct ToolBarCreateSheetAlbum: ToolbarContent {
    
    var cancelAction: () -> Void
    var confirmAction: () -> Void
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: .cancellationAction) {
            Button(action: cancelAction) {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button(action: confirmAction) {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
        
        
    }
}

//
//  ToolBarCreateMoment.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct ToolBarCreateMoment: ToolbarContent {
    var cancelAction: () -> Void
    var confirmAction: () -> Void
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: .cancellationAction) {
            Button(action: cancelAction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text("Criar momento")
                .font(.headline)
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button(action: confirmAction) {
                Image(systemName: "checkmark")
            }
        }
        
    }
}

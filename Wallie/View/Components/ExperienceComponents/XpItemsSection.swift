//
//  XpItemsSection.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI

struct XpItemsSection: View {
    @Binding var itens: [AddItem]
    
    var body: some View {
        if !itens.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($itens) { $item in
                    XpAddItemRow(item: $item) {
                        remover(item)
                    }
                    
                    if item.id != itens.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func remover(_ item: AddItem) {
        withAnimation {
            itens.removeAll { $0.id == item.id }
        }
    }
}

#Preview {
    @Previewable @State var itens = [
        AddItem(type: .mood),
        AddItem(type: .photo)
    ]
    
    XpItemsSection(itens: $itens)
}

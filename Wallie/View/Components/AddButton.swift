//
//  AddButton.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct ButtonAdd: View {
    @Binding var displaySheet: Bool
    var color: Color? = .blue
    
    var body: some View {
            Button(action: {
                displaySheet.toggle()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background((color ?? .blue))
                    .clipShape(Circle())
            }
        }
}

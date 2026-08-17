//
//  MosaicoView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct MosaicoView: View {
    var body: some View {
        
        VStack (alignment: .center) {
            HStack {
                Title(title: "Mosaico", subtitle: "")
            }
            .padding(.bottom, 50)
        }
    }
        
}
    
#Preview {
    MosaicoView()
}

//
//  MomentsView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct MomentsView : View {
    @State private var displaySheet = false
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .center) {
                    HStack {
                        Title(title: "Momentos", subtitle: "")
                        Spacer()
                        AddButton(displaySheet: $displaySheet)
                    }
                    .padding(.bottom, 50)
                    
                    Image("skineve")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 92, height: 140)
                }
                .padding(16)
                .sheet(isPresented: $displaySheet) {
                    CreateMomentView()
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    MomentsView()
}

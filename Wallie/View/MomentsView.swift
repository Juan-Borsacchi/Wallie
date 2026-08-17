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
            
            ZStack {
                Image("BackgroundMoments")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack (alignment: .center) {
                    HStack {
                        Title(title: "Momentos", subtitle: "")
                            .foregroundStyle(Color.white)
                    }
                    .padding(.bottom, 50)
                    
                    Image("skineve")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 350)
                        .cornerRadius(20)
                    
                    AddMoment(displaySheet: $displaySheet)
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
}

#Preview {
    MomentsView()
}

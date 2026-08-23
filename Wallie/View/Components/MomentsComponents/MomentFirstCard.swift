//
//  FirtsMoment.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct MomentFirstCard: View {
    
    var body: some View {
        VStack {
            Image("PrimeiroMomento")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Text("Capture e veja suas experiências")
                .font(.custom("Manrope-Bold", size: 26))
                .shadow(color: .black.opacity(0.2), radius: 2, x:2, y:2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white)
        }
    }
}

#Preview {
    MomentFirstCard()
}

//
//  TagDate.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct TagDate: View {
    
    var dateSelected: Date
    
    var formatoData: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }
    
    var body: some View {
        VStack {
            Text(formatoData.string(from: dateSelected))
                .font(.custom("Manrope-Bold", size: 17))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 16)
        .frame(height: 32)
        .background(Color.green)
        .cornerRadius(20)
    }
}

#Preview {
    TagDate(dateSelected: Date())
}

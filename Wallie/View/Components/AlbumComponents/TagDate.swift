//
//  TagDate.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct TagDate: View {
    @Environment(\.colorScheme) private var colorScheme
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
                .foregroundStyle(colorScheme == .dark ? .white : .primary)
        }
        .padding(.horizontal, 16)
        .frame(height: 32)
        .background(colorScheme == .dark ? .black : .white)
        .cornerRadius(20)
        .overlay(
            Capsule()
                .strokeBorder(Color(.separator), lineWidth: 2)
        )
    }
}

#Preview {
    TagDate(dateSelected: Date())
}

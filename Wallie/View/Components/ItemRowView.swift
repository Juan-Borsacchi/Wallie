//
//  ItemRowView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//


import SwiftUI

struct ItemRowView: View {
    let item: AddItem
    
    var body: some View {
        VStack(alignment: .leading) {
            switch item.content {
            case .audio:
                // Card de player igualzinho à foto 2
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Circle().fill(Color.accentColor))
                    
                    Text("0:01")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "bubble.left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Exemplo de forma de onda estilizada
                    HStack(spacing: 3) {
                        ForEach(0..<18, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.accentColor.opacity(0.7))
                                .frame(width: 3, height: CGFloat([10, 18, 24, 14, 28, 12, 20, 16, 26, 12, 18, 22, 10, 15, 20, 12, 18, 10][index]))
                        }
                    }
                }
                .padding()
                .background(Color.accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            case .image(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

            case .mood(let mood):
                HStack {
                    Text(mood)
                        .font(.title)
                    Text("Humor registrado")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            case .none:
                EmptyView()
            }
        }
    }
}

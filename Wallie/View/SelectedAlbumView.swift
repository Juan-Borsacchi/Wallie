//
//  SelectedAlbumView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct Post: Identifiable {
    let id = UUID()
    let color: Color
    let height: CGFloat
}

struct MasonryGridView: View {
    
    let posts: [Post] = [
        Post(color: .red, height: 200),
        Post(color: .red, height: 300),
        Post(color: .red, height: 150),
        Post(color: .red, height: 250),
        Post(color: .red, height: 350),
        Post(color: .red, height: 180),
        Post(color: .red, height: 220),
        Post(color: .red, height: 280)
    ]
    
    //Imagens em posições pares para a coluna da esquerda
    var leftColumn: [Post] {
        posts.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
    }
    
    //Imagens em posições ímpares para a coluna da direita
    var rightColumn: [Post] {
        posts.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Title(title: "Nome do Album", subtitle: "")
            }                
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 16) {
                        ForEach(leftColumn) { post in
                            ImageCard(post: post)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        ForEach(rightColumn) { post in
                            ImageCard(post: post)
                        }
                    }
                }
                .padding()
            }
    }
}

struct ImageCard: View {
    let post: Post
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(post.color.opacity(0.7))
            .frame(height: post.height)
    }
}

#Preview {
    MasonryGridView()
}

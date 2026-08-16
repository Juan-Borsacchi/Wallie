//
//  Album.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 14/08/26.
//

import SwiftUI
import PhotosUI

struct AlbumItem1: View {
    let imageAlbum1: String
    
    var body: some View {
        Group {
            if imageAlbum1.isEmpty {
                Color.white
            } else {
                Image(imageAlbum1)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 92, height: 140)
        .mask(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(imageAlbum1.isEmpty ? Color.gray.opacity(0.3) : .white, lineWidth: imageAlbum1.isEmpty ? 1 : 0.5)
        )
        .rotationEffect(.degrees(-5))
    }
}

struct AlbumItem2: View {
    let imageAlbum2: String
    
    var body: some View {
        Group {
            if imageAlbum2.isEmpty {
                Color.white
            } else {
                Image(imageAlbum2)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 92, height: 140)
        .mask(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(imageAlbum2.isEmpty ? Color.gray.opacity(0.3) : .white, lineWidth: imageAlbum2.isEmpty ? 1 : 0.5)
        )
        .rotationEffect(.degrees(5))
    }
}

struct LastImageAlbum: View {
    let imageLastAlbum: String
    let amountImages: String
    
    var body: some View {
        ZStack {
            Group {
                if imageLastAlbum.isEmpty {
                    Color.white
                } else {
                    Image(imageLastAlbum)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 92, height: 140)
            .mask(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(imageLastAlbum.isEmpty ? Color.gray.opacity(0.3) : .white, lineWidth: imageLastAlbum.isEmpty ? 1 : 0.5)
            )
            .rotationEffect(.degrees(5))
            .blur(radius: imageLastAlbum.isEmpty ? 0 : 2)
            
            Text(amountImages)
                .foregroundStyle(imageLastAlbum.isEmpty ? Color.black : Color.white)
                .fontWeight(.semibold)
        }
    }
}

struct AlbumGroup: View {
    let titleAlbum: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(titleAlbum)
                .font(.custom("Manrope-Bold", size: 22))
                .foregroundStyle(Color.blue)
            
            HStack(spacing: -5) {
                AlbumItem1(imageAlbum1: "")
                AlbumItem2(imageAlbum2: "")
                AlbumItem1(imageAlbum1: "")
                LastImageAlbum(imageLastAlbum: "", amountImages: "")
            }
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    AlbumGroup(titleAlbum: "Viagem para o Chile")
}

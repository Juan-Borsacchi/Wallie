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
        Image(imageAlbum1)
            .resizable()
            .scaledToFill()
            .frame(width: 92, height: 140)
            .mask(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white, lineWidth: 0.5)
            )
            .rotationEffect(.degrees(-5))
            
    }
}

struct AlbumItem2: View {
    
    let imageAlbum2: String
    
    var body: some View {
        Image(imageAlbum2)
            .resizable()
            .scaledToFill()
            .frame(width: 92, height: 140)
            .mask(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white, lineWidth: 0.5)
            )
            .rotationEffect(.degrees(5))
    }
}

struct LastImageAlbum: View {
    
    let imageLastAlbum: String
    let amountImages: String
    
    var body: some View {
        ZStack {
            Image(imageLastAlbum)
                .resizable()
                .scaledToFill()
                .frame(width: 92, height: 140)
                .mask(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white, lineWidth: 0.5)
                )
                .rotationEffect(.degrees(5))
                .blur(radius: 2)
            Text(amountImages)
                .foregroundStyle(Color.white)
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
                AlbumItem1(imageAlbum1: "skineve")
                AlbumItem2(imageAlbum2: "mountains")
                AlbumItem1(imageAlbum1: "canoalago")
                LastImageAlbum(imageLastAlbum: "outono", amountImages: "+ 3")
            }
        }
    }
}

#Preview {
   AlbumGroup(titleAlbum: "Viagem para o Chile")
}

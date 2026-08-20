//
//  Album.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 14/08/26.
//

import SwiftUI
import PhotosUI

struct AlbumItem1: View {
    let image: UIImage?
    
    var body: some View {
        Group {
            if let img = image  {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.white
                
            }
        }
        .frame(width: 92, height: 140)
        .mask(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(image == nil ? Color.gray.opacity(0.3) : .white, lineWidth: image == nil ? 1 : 0.5)
        )
        .rotationEffect(.degrees(-5))
    }
}

struct AlbumItem2: View {
    let image: UIImage?

    var body: some View {
        Group {
            if let img = image  {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.white
                
            }
        }
        .frame(width: 92, height: 140)
        .mask(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(image == nil ? Color.gray.opacity(0.3) : .white, lineWidth: image == nil ? 1 : 0.5)
        )
        .rotationEffect(.degrees(5))
    }
}

struct LastImageAlbum: View {
    let image: UIImage?
    let totalImagesCount: Int
    
    var body: some View {
        ZStack {
            Group {
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.white
                }
            }
            .frame(width: 92, height: 140)
            .mask(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(image == nil ? Color.gray.opacity(0.3) : .white, lineWidth: image == nil ? 1 : 0.5)
            )
            .rotationEffect(.degrees(5))
            .blur(radius: image == nil ? 0 : 2)
            
            if image == nil, totalImagesCount >= 4 {
                Text("+\(max(0, totalImagesCount - 4))")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
        }
    }
}

struct AlbumGroup: View {
    let titleAlbum: String
    let images: [UIImage]
    let totalCount: Int
    
    private func getImage(at index: Int) -> UIImage? {
        return images.indices.contains(index) ? images[index] : nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(titleAlbum)
                .font(.custom("Manrope-Bold", size: 22))
                .foregroundStyle(Color.blue)
            
            HStack(spacing: -5) {
                AlbumItem1(image: getImage(at: 0))
                AlbumItem2(image: getImage(at: 1))
                AlbumItem1(image: getImage(at: 2))
                LastImageAlbum(image: getImage(at: 3), totalImagesCount: totalCount)
            }
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    AlbumGroup(
        titleAlbum: "Viagem para o Chile",
        images: [],
        totalCount: 0)
}


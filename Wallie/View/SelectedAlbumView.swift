//
//  SelectedAlbumView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct SelectedAlbumView: View {
    
    let album: formAlbum
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                Title(title: album.name, subtitle: "")
                HStack {
                    if let catergory = album.category {
                        TagCategory(nameCategory: catergory)
                    }
                    
                    if let date = album.date {
                        TagDate(dateSelected: date)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
        }
    }
}


#Preview {
    SelectedAlbumView(album: formAlbum(name: "Viagem pro Chile", date: Date(), category: "Viagem"))
}

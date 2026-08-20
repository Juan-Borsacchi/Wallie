//
//  DateSelectionRow.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI

struct DateSelectionRow: View {
    @Binding var includeDate: Bool
    @Binding var date: Date
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text("Data")
                    .fontWeight(.medium)
                Spacer()
                Toggle("", isOn: $includeDate.animation())
                    .labelsHidden()
            }
            .padding(14)
            
            if includeDate {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            }
        }
        // Fundo ajustado para systemBackground
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct AlbumSelectionMenu: View {
    @Binding var album: String
    let availableAlbums: [String]
    
    var body: some View {
        Menu {
            ForEach(availableAlbums, id: \.self) { option in
                Button {
                    album = option
                } label: {
                    HStack {
                        Text(option)
                        if option == album {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "archivebox")
                    .foregroundStyle(.secondary)
                Text("Mover para álbum")
                    .fontWeight(.medium)
                Spacer()
                Text(album)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            // Fundo ajustado para systemBackground
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .foregroundStyle(.primary)
    }
}

//
//  AddExperienceView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI
import PhotosUI

struct AddExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    let existingID: UUID?
    let onSave: (Experience) -> Void
    
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var images: [Data]
    @State private var title: String
    @State private var description: String
    @State private var includeDate: Bool
    @State private var date: Date
    @State private var album: String
    
    private let availableAlbums = ["Nenhum", "Viagem", "Família", "Trabalho"]
    
    @State private var quality: QualityRating?
    @State private var emotion: EmotionTag?
    @State private var accentColor: Color?
    @State private var backgroundGradient: [Color]?
    @State private var activeTool: ToolSheet?
    
    private enum ToolSheet: String, Identifiable {
        case textStyle, colorBackground
        var id: String { rawValue }
    }
    
    init(editing experience: Experience? = nil, onSave: @escaping (Experience) -> Void) {
        self.existingID = experience?.id
        self.onSave = onSave
        _images = State(initialValue: experience?.images ?? [])
        _title = State(initialValue: experience?.title ?? "")
        _description = State(initialValue: experience?.description ?? "")
        _includeDate = State(initialValue: experience?.includeDate ?? false)
        _date = State(initialValue: experience?.date ?? Date())
        _album = State(initialValue: experience?.album ?? "Nenhum")
        _quality = State(initialValue: experience?.quality)
        _emotion = State(initialValue: experience?.emotion)
        _accentColor = State(initialValue: experience?.accentColor)
        _backgroundGradient = State(initialValue: experience?.backgroundGradient)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        photoCarousel
                        
                        if images.isEmpty {
                            Text("É necessário selecionar uma imagem para adicionar sua experiência.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        TextField("Dê um título para sua experiência...", text: $title)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        TextField("Escreva uma descrição", text: $description, axis: .vertical)
                            .lineLimit(3...8)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        dateRow
                        albumRow
                        qualityRow
                        emotionRow
                        toolbar
                    }
                    .padding(20)
                    .padding(.bottom, 90)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(.systemGray5)))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(existingID == nil ? "Adicionar experiência" : "Editar experiência")
                        .font(.headline)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let experience = Experience(
                            id: existingID ?? UUID(),
                            images: images,
                            title: title,
                            description: description,
                            includeDate: includeDate,
                            date: date,
                            album: album,
                            quality: quality,
                            emotion: emotion,
                            accentColor: accentColor,
                            backgroundGradient: backgroundGradient
                        )
                        onSave(experience)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(images.isEmpty ? Color.gray : MomentosPalette.accentSoft))
                    }
                    .disabled(images.isEmpty)
                }
            }
            .onChange(of: pickerItems) { _, newItems in loadImages(from: newItems) }
            .sheet(item: $activeTool) { tool in
                switch tool {
                case .textStyle: TextStyleSheet()
                case .colorBackground:
                    ColorBackgroundPickerSheet(accentColor: $accentColor, backgroundGradient: $backgroundGradient)
                }
            }
        }
    }
    
    // MARK: - Funções e Views Secundárias
    private var photoCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(alignment: .topLeading) {
                                if index == 0 {
                                    Text("Capa")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(.black.opacity(0.5)))
                                        .padding(6)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                Button { images.remove(at: index) } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                        .padding(6)
                                }
                            }
                    }
                }
                
                PhotosPicker(selection: $pickerItems, maxSelectionCount: 6, matching: .images) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black)
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        )
                }
            }
            .padding(.horizontal, 2)
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            var loaded: [Data] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) { loaded.append(data) }
            }
            images.append(contentsOf: loaded)
            pickerItems = []
        }
    }
    
    private var dateRow: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar").foregroundStyle(.secondary)
                Text("Data")
                Spacer()
                Toggle("", isOn: $includeDate.animation()).labelsHidden()
            }
            .padding(14)
            if includeDate {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            }
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private var albumRow: some View {
        Menu {
            ForEach(availableAlbums, id: \.self) { option in
                Button(option) { album = option }
            }
        } label: {
            HStack {
                Image(systemName: "archivebox").foregroundStyle(.secondary)
                Text("Mover para álbum").foregroundStyle(.primary)
                Spacer()
                Text(album).foregroundStyle(.secondary)
                Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
    
    private var qualityRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como foi?").font(.subheadline.weight(.semibold))
            HStack(spacing: 8) {
                ForEach(QualityRating.allCases) { rating in
                    Button { quality = quality == rating ? nil : rating } label: {
                        VStack(spacing: 5) {
                            Text(rating.emoji).font(.title3)
                            Text(rating.label).font(.caption2.weight(.medium)).lineLimit(1).minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(quality == rating ? Color.accentColor.opacity(0.18) : Color(.systemGray6))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(quality == rating ? Color.accentColor.opacity(0.65) : Color.clear, lineWidth: 1.5)
                        }
                        .foregroundStyle(quality == rating ? Color.accentColor : .primary)
                    }.buttonStyle(.plain)
                }
            }
        }
    }
    
    private var emotionRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como se sentiu?").font(.subheadline.weight(.semibold))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(EmotionTag.allCases) { tag in
                    Button { emotion = emotion == tag ? nil : tag } label: {
                        VStack(spacing: 4) {
                            Text(tag.emoji).font(.title3)
                            Text(tag.label).font(.caption2.weight(.medium)).lineLimit(1).minimumScaleFactor(0.75)
                            if emotion == tag {
                                Image(systemName: "checkmark.circle.fill").font(.caption2)
                            }
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(emotion == tag ? Color.accentColor.opacity(0.18) : Color(.systemGray6))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(emotion == tag ? Color.accentColor.opacity(0.65) : Color.clear, lineWidth: 1.5)
                        }
                        .foregroundStyle(emotion == tag ? Color.accentColor : .primary)
                    }.buttonStyle(.plain)
                }
            }
        }
    }
    
    private var toolbar: some View {
        HStack(spacing: 0) {
            toolButton(symbol: "textformat") { activeTool = .textStyle }
            ZStack {
                toolButton(symbol: "photo.on.rectangle") {}
                PhotosPicker(selection: $pickerItems, maxSelectionCount: 6, matching: .images) { Color.clear }
            }
            toolButton(symbol: "paintpalette") { activeTool = .colorBackground }
        }
        .padding(.vertical, 10)
        .background(.thickMaterial)
    }
    
    private func toolButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
        }.buttonStyle(.plain)
    }
}

// MARK: - Sub Sheets (Mantenha-os neste arquivo)
private struct TextStyleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selected = "Padrão"
    private let options = ["Padrão", "Serifada", "Arredondada", "Monoespaçada"]
    
    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(Color(.systemGray4)).frame(width: 40, height: 5).padding(.top, 8)
            Text("Estilo de texto").font(.headline)
            ForEach(options, id: \.self) { option in
                Button {
                    selected = option
                    dismiss()
                } label: {
                    HStack {
                        Text(option)
                        Spacer()
                        if option == selected { Image(systemName: "checkmark") }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }.foregroundStyle(.primary)
            }
            Spacer()
        }
        .presentationDetents([.height(300)])
    }
}

private struct ColorBackgroundPickerSheet: View {
    @Binding var accentColor: Color?
    @Binding var backgroundGradient: [Color]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Capsule().fill(Color(.systemGray4)).frame(width: 40, height: 5).frame(maxWidth: .infinity).padding(.top, 8)
            Text("Cor").font(.headline).padding(.horizontal, 20)
            HStack(spacing: 14) {
                ForEach(MomentosPalette.colorSwatches, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay {
                            if accentColor == color {
                                Circle().stroke(.primary, lineWidth: 2).padding(-3)
                            }
                        }
                        .onTapGesture { accentColor = color }
                }
            }.padding(.horizontal, 20)
            
            Text("Plano de fundo").font(.headline).padding(.horizontal, 20).padding(.top, 6)
            HStack(spacing: 14) {
                ForEach(Array(MomentosPalette.backgroundSwatches.enumerated()), id: \.offset) { _, gradientColors in
                    Circle()
                        .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                        .overlay {
                            if backgroundGradient == gradientColors {
                                Circle().stroke(.primary, lineWidth: 2).padding(-3)
                            }
                        }
                        .onTapGesture { backgroundGradient = gradientColors }
                }
            }.padding(.horizontal, 20)
            Spacer()
        }
        .presentationDetents([.height(320)])
    }
}

#Preview {
    AddExperienceView(editing: .mock) { _ in }
}

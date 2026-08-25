//
//  DataManager.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class DataManager {
    static let shared = DataManager()
    
    var xperiences: [Xperience] = []
    var albums: [Album] = []
    
    private var modelContext: ModelContext?
    
    private init() {}
    
    func setContext(_ context: ModelContext) {
            self.modelContext = context
            loadData()
        }
    
    func loadData() {
        guard let context = modelContext else { return }
        
        do {

            let experienceDescriptor = FetchDescriptor<Xperience>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let albumDescriptor = FetchDescriptor<Album>(
                sortBy: [SortDescriptor(\.title, order: .forward)]
            )
            
            self.xperiences = try context.fetch(experienceDescriptor)
            self.albums = try context.fetch(albumDescriptor)
        } catch {
            print("Erro ao carregar dados: \(error.localizedDescription)")
        }
    }
    
    func saveExperience(_ experienceUI: Experience) {
        guard let context = modelContext else { return }
        
        let targetId = experienceUI.id
        let descriptor = FetchDescriptor<Xperience>(
            predicate: #Predicate { $0.id == targetId }
        )
        
        let xperience: Xperience
        if let existing = try? context.fetch(descriptor).first {
            xperience = existing
        } else {
            xperience = Xperience()
            xperience.id = experienceUI.id
            context.insert(xperience)
        }
        
        xperience.title = experienceUI.title
        xperience.descriptions = experienceUI.description
        xperience.timestamp = experienceUI.date
        xperience.includeDate = experienceUI.includeDate
        xperience.sensation = experienceUI.quality?.rawValue
        xperience.feelings = experienceUI.emotion?.rawValue
        
        if let coverData = experienceUI.images.first {
            xperience.cover = coverData
        }
        
        // Reseta antes de popular
        xperience.audio = nil
        xperience.photos = nil
        
        var allExtraImagesData: [Data] = []
        
        for item in experienceUI.extraItems {
            switch item.content {
            case .audio(let url):
                do {

                    let audioData = try Data(contentsOf: url)
                    xperience.audio = audioData
                } catch {
                    print("Não foi possível carregar os dados do áudio na URL: \(url) - Erro: \(error.localizedDescription)")
                }
            case .images(let datas):
                allExtraImagesData.append(contentsOf: datas)
            default:
                break
            }
        }
        
        if !allExtraImagesData.isEmpty {
            xperience.photos = try? NSKeyedArchiver.archivedData(withRootObject: allExtraImagesData, requiringSecureCoding: true)
        } else {
            xperience.photos = nil
        }
        
        if experienceUI.album != "Nenhum" {
            xperience.album = getOrCreateAlbum(withName: experienceUI.album, in: context)
        } else {
            xperience.album = nil
        }
        
        saveContext(context)
    }
    
    func saveAlbum(_ albumUI: formAlbum) {
        guard let context = modelContext else { return }
        
        let targetId = albumUI.id
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.id == targetId }
        )
        
        if let existingAlbum = try? context.fetch(descriptor).first {
            existingAlbum.title = albumUI.name
            existingAlbum.category = albumUI.category
            existingAlbum.date = albumUI.date ?? Date()
        } else {
            let album = Album()
            album.id = albumUI.id
            album.title = albumUI.name
            album.category = albumUI.category
            album.date = albumUI.date ?? Date()
            context.insert(album)
        }
        
        saveContext(context)
    }
    
    private func getOrCreateAlbum(withName name: String, in context: ModelContext) -> Album {
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.title == name }
        )
        
        if let existingAlbum = try? context.fetch(descriptor).first {
            return existingAlbum
        }
        
        let newAlbum = Album()
        newAlbum.id = UUID()
        newAlbum.title = name
        context.insert(newAlbum)
        return newAlbum
    }
    
    func deleteExperience(_ xperience: Xperience) {
        guard let context = modelContext else { return }
        context.delete(xperience)
        saveContext(context)
    }
    
    func deleteAlbum(_ albumUI: formAlbum) {
            guard let context = modelContext else { return }
            
            let targetID = albumUI.id
            let descriptor = FetchDescriptor<Album>(
                predicate: #Predicate { $0.id == targetID }
            )
            
            do {
                if let albumToDelete = try context.fetch(descriptor).first {
                    if let associatedExperiences = albumToDelete.xperiences {
                        for exp in associatedExperiences {
                            exp.album = nil
                        }
                    }
                    
                    context.delete(albumToDelete)
                    try context.save()
                    loadData()
                }
            } catch {
                print("Erro ao deletar álbum: \(error.localizedDescription)")
            }
        }
    
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
            loadData()
        } catch {
            print("Erro ao salvar contexto: \(error.localizedDescription)")
        }
    }
}

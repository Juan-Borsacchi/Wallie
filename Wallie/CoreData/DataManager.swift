//
//  DataManager.swift
//  Wallie
//
//  Created by Tais Akemi Kawaguti on 18/08/26.
//

internal import CoreData
import UIKit
import SwiftUI
import Combine

class DataManager: ObservableObject {
    
    static let shared = DataManager()
    
    @Published var xperiences: [Xperience] = []
    
    // Salva uma nova experiência
    func saveExperience(with title: String, cover: UIImage) {
        let managedContext = PersistenceController.shared.container.viewContext
         
        let newXperience = Xperience(context: managedContext)
         
        newXperience.id = UUID()
        newXperience.title = title
        newXperience.timestamp = Date()
         
        if let imageData = cover.jpegData(compressionQuality: 0.8) {
            newXperience.cover = imageData //salvar externo do projeto
        }
         
        do {
            try managedContext.save()
            print("Salvo com sucesso!")
            loadData() // Atualiza a lista após salvar
        } catch let error as NSError {
            print("Não deu para salvar. \(error), \(error.userInfo)")
        }
    }

    // Busca todas as experiências salvas no banco de dados
    func loadData() {
        let fetchRequest: NSFetchRequest<Xperience> = Xperience.fetchRequest()
        let context = PersistenceController.shared.container.viewContext
         
        do {
            let results = try context.fetch(fetchRequest)
            self.xperiences = results
        } catch {
            print("Erro ao recuperar dados: \(error)")
        }
    }
     
    // Atualiza a experiência buscando especificamente pelo ID
    func updateExperience(id: UUID, newTitle: String, newCover: UIImage?) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Xperience> = Xperience.fetchRequest()
         
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
         
        do {
            let results = try context.fetch(fetchRequest)
             
            if let experienceToUpdate = results.first {
                experienceToUpdate.title = newTitle
                 
                if let cover = newCover, let imageData = cover.jpegData(compressionQuality: 0.8) {
                    experienceToUpdate.cover = imageData
                }
                 
                try context.save()
                print("Experiência atualizada com sucesso pelo ID!")
                loadData()
            } else {
                print("Nenhuma experiência encontrada com o ID informado.")
            }
        } catch {
            print("Erro ao atualizar por ID: \(error.localizedDescription)")
        }
    }
     
    // Atualiza apenas o título de uma tarefa/experiência existente
    func updateTitleExp(task: Xperience, newTitle: String) {
        let context = PersistenceController.shared.container.viewContext
        task.title = newTitle
         
        do {
            try context.save()
            loadData()
        } catch {
            print("Update error: \(error.localizedDescription)")
        }
    }
     
    // Deleta uma experiência
    func deleteTask(task: Xperience) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(task)
         
        do {
            try context.save()
            loadData()
        } catch {
            print("Delete error: \(error.localizedDescription)")
        }
    }
}

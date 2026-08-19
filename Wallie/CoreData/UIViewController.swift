//
//  XperienceTableViewController.swift
//  Wallie
//
//  Created by Tais Akemi Kawaguti on 18/08/26.
//

import UIKit

class XperienceTableViewController: UITableViewController {
    
    let dataManager = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Carrega os dados atualizados e recarrega a tabela
        dataManager.loadData()
        tableView.reloadData()
    }
    
    // MARK: - Métodos da TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.xperiences.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let experience = dataManager.xperiences[indexPath.row]
        cell.textLabel?.text = experience.title
        
        if let data = experience.cover, let image = UIImage(data: data) {
            cell.imageView?.image = image
        }
        
        return cell
    }
    
    // Método auxiliar para atualizar uma experiência a partir da linha selecionada
    func updateExperienceFromCell(indexPath: IndexPath, newTitle: String, newCover: UIImage?) {
        let experience = dataManager.xperiences[indexPath.row]
         
        guard let id = experience.id else { return }
         
        // Chama o método correto correspondente ao DataManager atualizado
        dataManager.updateExperience(id: id, newTitle: newTitle, newCover: newCover)
        
        // Recarrega a tabela visualmente
        tableView.reloadData()
    }
}

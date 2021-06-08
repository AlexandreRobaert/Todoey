//
//  HomeTableViewController.swift
//  Todoey
//
//  Created by Alexandre Robaert on 27/05/21.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {

    var items: [Tarefa] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAlertAdd))
        button.tintColor = .white
        self.navigationItem.rightBarButtonItem = button
        loadItems()
    }
    
    func loadItems(){
        let request: NSFetchRequest<Tarefa> = Tarefa.fetchRequest();
        do{
            items = try context.fetch(request)
            self.tableView.reloadData()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    @objc func showAlertAdd(){
        let alert = UIAlertController(title: "Adicionar", message: "Adicionar Item a lista", preferredStyle: .alert)
        alert.addTextField { textF in
            textF.placeholder = "Novo Item"
        }
        let actionAdicionar = UIAlertAction(title: "Adicionar", style: .default) { alertAction in
            if let text = alert.textFields?[0].text{
                let tarefa = Tarefa(context: self.context)
                tarefa.title = text
                self.saveItems()
                self.items.append(tarefa)
                self.loadItems()
            }
        }
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(actionAdicionar)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertDeleteFor(item: Tarefa){
        let alertController = UIAlertController(title: item.title, message: "Deletar Tarefa?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Deletar", style: .default) { alert in
            self.context.delete(item)
            self.saveItems()
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func saveItems(){
        do {
            try self.context.save()
        }catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        cell.accessoryType = items[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType =  cell?.accessoryType == .checkmark ? .none : .checkmark
        self.items[indexPath.row].done = !self.items[indexPath.row].done
        saveItems()
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showAlertDeleteFor(item: self.items[indexPath.row])
        }
    }
}

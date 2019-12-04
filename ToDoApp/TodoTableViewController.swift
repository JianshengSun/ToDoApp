//
//  TodoTableViewController.swift
//  ToDoApp
//
//  Created by Jason on 2019-12-01.
//  Copyright © 2019 centennialcollege. All rights reserved.
//

import UIKit
import CoreData

class TodoTableViewController: UITableViewController {
    
    var resultsController: NSFetchedResultsController<TODO>!
    let coreDataStack = CoreDataStack()
    var importancestar = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request
        let request: NSFetchRequest<TODO> = TODO.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        //init
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        resultsController.delegate = self
        
        //fetch
        do {
            try resultsController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
    }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        
        // Configure the cell...
        let todo = resultsController.object(at: indexPath)
        if todo.priotity == Int16(0) {
            importancestar = ""
        } else if todo.priotity == Int16(1) {
            importancestar = "❗️"
        } else if todo.priotity == Int16(2) {
            importancestar = "‼️"
        } else {importancestar = ""}
        if todo.done{
            cell.backgroundColor = #colorLiteral(red: 0.9098, green: 0.9098, blue: 0.9098, alpha: 1) /* #e8e8e8 */
            cell.textLabel?.textColor = #colorLiteral(red: 0.7765, green: 0.7765, blue: 0.7765, alpha: 1) /* #c6c6c6 */
            cell.textLabel?.text = importancestar + todo.title!
        } else {
            cell.textLabel?.text = importancestar + todo.title!
        }
        
        

        return cell
    }
    

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }

        }
        //action.image = #imageLiteral(resourceName: "check-icon")
        action.backgroundColor = .red
        
        
        return UISwipeActionsConfiguration(actions:[action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            let todo = self.resultsController.object(at: indexPath)
            todo.done = true
            tableView.reloadData()
            //something
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("done failed: \(error)")
                completion(false)
            }
        }
        //action.image = #imageLiteral(resourceName: "check")
        action.backgroundColor = .green
        
        
        return UISwipeActionsConfiguration(actions:[action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = resultsController.object(at: indexPath)
        performSegue(withIdentifier: "ShowAddTodo", sender: tableView.cellForRow(at: indexPath))}
        
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */



    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let todo = resultsController.object(at: indexPath)
                vc.todo = todo
            }

        }
    }
    

}
extension TodoTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultsController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultsController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }


        default:
            break
        }
    }


    
}

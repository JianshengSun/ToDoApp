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

    //the number of the cell
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    //set tableview cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        
        // Configure the cell...
        let todo = resultsController.object(at: indexPath)
        //edit priotities: low with nothing, mid with ❗️, high with ‼️
        if todo.priotity == Int16(0) {
            importancestar = ""
        } else if todo.priotity == Int16(1) {
            importancestar = "❗️"
        } else if todo.priotity == Int16(2) {
            importancestar = "‼️"
        } else {importancestar = ""}
        //edit task which is donw, change the background color to gray
        if todo.done{
            cell.backgroundColor = #colorLiteral(red: 0.9098, green: 0.9098, blue: 0.9098, alpha: 1) /* #e8e8e8 */
            cell.textLabel?.textColor = #colorLiteral(red: 0.7765, green: 0.7765, blue: 0.7765, alpha: 1) /* #c6c6c6 */
            cell.textLabel?.text = importancestar + todo.title!
        } else {
            //bug fix(reset coloer, if not, add new task will still the gray color)
            cell.backgroundColor = .white
            cell.textLabel?.textColor = .black
            cell.textLabel?.text = importancestar + todo.title!
        }
        return cell
    }
    
    //left slide to delete
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
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions:[action])
    }
    
    //right slide to finish todo task
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            let todo = self.resultsController.object(at: indexPath)
            //set task to done
            todo.done = true
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("done failed: \(error)")
                completion(false)
            }
            //reloade the tableview
            tableView.reloadData()
        }
        action.backgroundColor = #colorLiteral(red: 1, green: 0.8667, blue: 0, alpha: 1) /* #ffdd00 */
        return UISwipeActionsConfiguration(actions:[action])
    }
    
    //selectrow to edit
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddTodo", sender: tableView.cellForRow(at: indexPath))}
        
    //prepare managedContext
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

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
        //insert
        case .insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        //delete
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        //update
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultsController.object(at: indexPath)
                //edit priotity information when update
                if todo.priotity == Int16(0) {
                    importancestar = ""
                } else if todo.priotity == Int16(1) {
                    importancestar = "❗️"
                } else if todo.priotity == Int16(2) {
                    importancestar = "‼️"
                } else {importancestar = ""}
                cell.textLabel?.text = importancestar + todo.title!
            }
        default:
            break
        }
    }
}

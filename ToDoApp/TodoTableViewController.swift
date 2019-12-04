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
    
    var resultsController: NSFetchedResultsController<Todo>!
    let coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        //init
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
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
        return resultsController.sections?[section].objects?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

                // Configure the cell...
        let todo = resultsController.object(at: indexPath)
        cell.textLabel?.text = todo.title

        return cell
    }
    

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            completion(true)
        }
        action.image = UIImage(named: "trash-icon.png")
        action.backgroundColor = .red
        
        
        return UISwipeActionsConfiguration(actions:[action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            completion(true)
        }
        action.image = UIImage(named: "check-icon.png")
        action.backgroundColor = .green
        
        
        return UISwipeActionsConfiguration(actions:[action])
    }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = coreDataStack.managedContext
        }
    }
    

}

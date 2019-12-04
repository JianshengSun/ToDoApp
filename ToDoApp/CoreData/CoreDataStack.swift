//
//  CoreDataStack.swift
//  ToDoApp
//
//  Created by Jason on 2019-12-03.
//  Copyright © 2019 centennialcollege. All rights reserved.
//

import Foundation
import CoreData



class CoreDataStack {
    var container: NSPersistentContainer{
        let container = NSPersistentContainer(name: "Todos")
        container.loadPersistentStores {(description, error) in guard error == nil else {
            print("Error: \(error!)")
            return
            }
            
        }
        return container
    }
    
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
}

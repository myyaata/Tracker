//
//  CoreDataStack.swift
//  Tracker
//
//  Created by арина сильченко on 9.10.26.
//

import Foundation
import CoreData

final class CoreDataStack {
    private let inMemory: Bool
    
    init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                print("Ошибка сохранения: \(error)")
            }
        }
    }
}

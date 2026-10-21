//
//  TrackerStore.swift
//  Tracker
//
//  Created by арина сильченко on 13.10.26.
//

import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        _ = fetchedResultsController
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Failed to fetch trackers: \(error)")
        }
        return fetchedResultsController
    }()
    
    func addNewTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.category = try fetchOrCreateCategory(with: categoryTitle)
        trackerCoreData.colorName = tracker.colorName
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
        try context.save()
    }
    
    func fetchTrackers() -> [Tracker] {
        let trackersCoreData = fetchedResultsController.fetchedObjects ?? []
        return trackersCoreData.compactMap { $0.toTracker() }
    }
    
    private func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        if let existing = try context.fetch(request).first {
            return existing
        }
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        return newCategory
    }
}


extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard let id = self.id, let name = self.name, let colorName = self.colorName, let emoji = self.emoji, let schedule = self.schedule as? [WeekDay] else {
            return nil
        }
        return Tracker(id: id, name: name, colorName: colorName, emoji: emoji, schedule: schedule)
    }
}

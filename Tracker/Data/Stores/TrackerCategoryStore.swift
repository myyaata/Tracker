//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by арина сильченко on 13.10.26.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidUpdate()
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        _ = fetchedResultsController
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
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
    
    func fetchCategories() -> [TrackerCategory] {
        let categoriesCoreData = fetchedResultsController.fetchedObjects ?? []
        return categoriesCoreData.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title else { return nil }
            let trackersCoreData = (categoryCoreData.trackers as? Set<TrackerCoreData>) ?? []
            let trackers = trackersCoreData.sorted { ($0.name ?? "") < ($1.name ?? "" ) }.compactMap{ $0.toTracker() }
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidUpdate()
    }
}

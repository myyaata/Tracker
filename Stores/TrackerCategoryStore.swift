//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by арина сильченко on 13.10.26.
//

import CoreData
import UIKit

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
    
    override convenience init() {
        self.init(context: (UIApplication.shared.delegate as! AppDelegate).coreDataStack.context)
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
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

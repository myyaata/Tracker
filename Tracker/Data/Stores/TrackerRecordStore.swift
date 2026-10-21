//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by арина сильченко on 13.10.26.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate()
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerRecordStoreDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        _ = fetchedResultsController
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
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
    
    func fetchRecords() -> [TrackerRecord] {
        let recordsCoreData = fetchedResultsController.fetchedObjects ?? []
        return recordsCoreData.compactMap { recordCoreData in
            guard let id = recordCoreData.tracker?.id, let date = recordCoreData.date else { return nil }
            return TrackerRecord(id: id, date: date)
        }
    }
    
    func addNewRecord(_ trackerRecord: TrackerRecord) throws {
        let request = TrackerCoreData.fetchRequest()
        let trackerId = trackerRecord.id
        request.predicate = NSPredicate(format: "%K == %@", "id", trackerId as CVarArg)
        guard let tracker = try context.fetch(request).first else { return }
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = trackerRecord.date
        recordCoreData.tracker = tracker
        try context.save()
    }
    
    func deleteRecord(_ trackerRecord: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: trackerRecord.date)
        guard let startOfNextDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K >= %@ AND %K < %@",
            "tracker.id", trackerRecord.id as CVarArg,
            "date", startOfDay as NSDate,
            "date", startOfNextDay as NSDate)
        guard let record = try context.fetch(request).first else { return }
        context.delete(record)
        try context.save()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidUpdate()
    }
}

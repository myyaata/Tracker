//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by арина сильченко on 13.10.26.
//

import CoreData
import UIKit

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        self.init(context: (UIApplication.shared.delegate as! AppDelegate).coreDataStack.context)
    }
}

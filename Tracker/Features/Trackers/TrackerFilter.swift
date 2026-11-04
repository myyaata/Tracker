//
//  TrackerFilter.swift
//  Tracker
//
//  Created by арина сильченко on 4.11.26.
//
import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all: NSLocalizedString("filters.all", comment: "")
        case .today: NSLocalizedString("filters.today", comment: "")
        case .completed: NSLocalizedString("filters.completed", comment: "")
        case .uncompleted: NSLocalizedString("filters.uncompleted", comment: "")
        }
    }
}

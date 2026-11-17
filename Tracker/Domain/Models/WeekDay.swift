//
//  WeekDay.swift
//  Tracker
//
//  Created by арина сильченко on 15.09.26.
//

import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var shortTitle: String {
        switch self {
        case .sunday: NSLocalizedString("weekday.short.sunday", comment: "")
        case .monday: NSLocalizedString("weekday.short.monday", comment: "")
        case .tuesday: NSLocalizedString("weekday.short.tuesday", comment: "")
        case .wednesday: NSLocalizedString("weekday.short.wednesday", comment: "")
        case .thursday: NSLocalizedString("weekday.short.thursday", comment: "")
        case .friday: NSLocalizedString("weekday.short.friday", comment: "")
        case .saturday: NSLocalizedString("weekday.short.saturday", comment: "")
        }
    }
    
    var fullTitle: String {
        switch self {
        case .sunday: NSLocalizedString("weekday.full.sunday", comment: "")
        case .monday: NSLocalizedString("weekday.full.monday", comment: "")
        case .tuesday: NSLocalizedString("weekday.full.tuesday", comment: "")
        case .wednesday: NSLocalizedString("weekday.full.wednesday", comment: "")
        case .thursday: NSLocalizedString("weekday.full.thursday", comment: "")
        case .friday: NSLocalizedString("weekday.full.friday", comment: "")
        case .saturday: NSLocalizedString("weekday.full.saturday", comment: "")
        }
    }
    
    //день недели для конкретной даты
    static func from(date: Date) -> WeekDay {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        return WeekDay(rawValue: weekdayNumber) ?? .monday
    }
}

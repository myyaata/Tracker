//
//  WeekDay.swift
//  Tracker
//
//  Created by арина сильченко on 15.09.26.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var shortTitle: String {
        switch self {
        case .sunday: return "Вс"
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        }
    }
    
    var fullTitle: String {
        switch self {
        case .sunday: return "Воскресенье"
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        }
    }
    
    //день недели для конкретной даты
    static func from(date: Date) -> WeekDay {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        return WeekDay(rawValue: weekdayNumber) ?? .monday
    }
}

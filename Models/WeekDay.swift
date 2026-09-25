//
//  WeekDay.swift
//  Tracker
//
//  Created by арина сильченко on 15.09.26.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday 
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var shortTitle: String {
        switch self {
        case .sunday: "Вс"
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        }
    }
    
    var fullTitle: String {
        switch self {
        case .sunday: "Воскресенье"
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        }
    }
    
    //день недели для конкретной даты
    static func from(date: Date) -> WeekDay {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        return WeekDay(rawValue: weekdayNumber) ?? .monday
    }
}

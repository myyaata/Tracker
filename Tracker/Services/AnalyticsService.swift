//
//  AnalyticsService.swift
//  Tracker
//
//  Created by арина сильченко on 4.11.26.
//

import AppMetricaCore

enum AnalyticsEvent: String {
    case open, close, click
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track, filter, edit, delete
}

enum AnalyticsService {
    static func report(event: AnalyticsEvent, screen: String, item: AnalyticsItem? = nil) {
        var params: [AnyHashable: Any] = ["event": event.rawValue, "screen": screen]
        if let item {
            params["item"] = item.rawValue
        }
        print("Analytics:", params)
        AppMetrica.reportEvent(name: "ui_event", parameters: params) { error in
            print("Analytics error:", error.localizedDescription)
        }
    }
}

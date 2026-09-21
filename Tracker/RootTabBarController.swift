//
//  RootTabBarController.swift
//  Tracker
//
//  Created by арина сильченко on 1.09.26.
//

import UIKit

final class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        tabBar.tintColor = UIColor(named: "Blue")
        tabBar.unselectedItemTintColor = UIColor(named: "Gray")
    }

    private func setupTabs() {
        let trackers = TrackersViewController()
        trackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "record.circle.fill")?.withRenderingMode(.alwaysTemplate),
        )
        let trackersNav = UINavigationController(rootViewController: trackers)
        
        let statistics = StatisticsViewController()
        statistics.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "hare.fill")?.withRenderingMode(.alwaysTemplate),
        )
        let statisticsNav = UINavigationController(rootViewController: statistics)
        
        viewControllers = [trackersNav, statisticsNav]
    }
    
}

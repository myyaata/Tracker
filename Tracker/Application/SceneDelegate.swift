//
//  SceneDelegate.swift
//  Tracker
//
//  Created by арина сильченко on 1.09.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let coreDataStack = CoreDataStack()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let trackerStore = TrackerStore(context: coreDataStack.context)
        let trackerCategoryStore = TrackerCategoryStore(context: coreDataStack.context)
        let trackerRecordStore = TrackerRecordStore(context: coreDataStack.context)
        window.rootViewController = RootTabBarController(trackerStore: trackerStore,
                                                         trackerCategoryStore: trackerCategoryStore,
                                                         trackerRecordStore: trackerRecordStore)
        self.window = window
        window.makeKeyAndVisible()
    }
}


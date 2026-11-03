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
        let tabBar = RootTabBarController(trackerStore: trackerStore,
                                          trackerCategoryStore: trackerCategoryStore,
                                          trackerRecordStore: trackerRecordStore)
        let key = "hasSeenOnboarding"
        if UserDefaults.standard.bool(forKey: key) {
            window.rootViewController = tabBar
        } else {
            let onboarding = OnboardingViewController()
            onboarding.onFinish = { [weak self] in
                UserDefaults.standard.set(true, forKey: key)
                self?.window?.rootViewController = tabBar
            }
            window.rootViewController = onboarding
        }
        self.window = window
        window.makeKeyAndVisible()
    }
}


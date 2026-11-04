//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by арина сильченко on 4.11.26.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testMainScreenLight() {
        let stack = CoreDataStack(inMemory: true)
        let vc = RootTabBarController(
            trackerStore: TrackerStore(context: stack.context),
            trackerCategoryStore: TrackerCategoryStore(context: stack.context),
            trackerRecordStore: TrackerRecordStore(context: stack.context)
        )
        assertSnapshot(of: vc, as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)))
    }
}


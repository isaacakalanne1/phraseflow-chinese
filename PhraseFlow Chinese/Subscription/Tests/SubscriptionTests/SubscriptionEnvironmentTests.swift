//
//  SubscriptionEnvironmentTests.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import XCTest
import StoreKit
@testable import Subscription

final class SubscriptionEnvironmentTests: XCTestCase {
    func testSubscriptionEnvironmentImplementsProtocol() {
        let environment = SubscriptionEnvironment()
        XCTAssertNotNil(environment as SubscriptionEnvironmentProtocol)
    }
}
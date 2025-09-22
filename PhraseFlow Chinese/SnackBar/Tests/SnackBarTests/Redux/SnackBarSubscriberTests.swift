//
//  SnackBarSubscriberTests.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 22/09/2025.
//

//
//  SubscriptionSubscriberTests.swift
//  Subscription
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Combine
import Testing
import ReduxKit
@testable import Settings
@testable import SettingsMocks
@testable import SnackBar
@testable import SnackBarMocks

// MARK: - SnackBarSubscriberTests

@MainActor
final class SnackBarSubscriberTests {
    var mockEnvironment: MockSnackBarEnvironment
    var mockStore: MockStore<SnackBarState, SnackBarAction, SnackBarEnvironmentProtocol>!
    var suscriptions: Set<AnyCancellable> = []

    init() {
        mockEnvironment = MockSnackBarEnvironment()

        mockStore = MockStore(
            initial: .init(),
            reducer: snackBarReducer,
            environment: mockEnvironment,
            middleware: snackBarMiddleware
        )

        suscriptions = []
    }

    // MARK: All values

    @Test
    func test_storeObserves_allValues() async {
        let expectedActions = expectedActions_allValues()

        await assertDispatchedActions(expectedActions)
    }

    @Test
    func test_storeObserves_allValues_removeDuplicate() async {
        var expectedActions = expectedActions_allValues()

        let type = SnackBarType.none
        let duplicateAction = SnackBarAction.setType(type)

        expectedActions.append(duplicateAction)

        await assertDispatchedActions(expectedActions) {
            self.mockEnvironment.snackbarStatus.send(type)
        }
    }

    // MARK: - Assert

    func assertDispatchedActions(
        _ expectedActions: [SnackBarAction],
        afterSetup setup: () -> Void = { /* no need to implementation */ },
        timeout: TimeInterval = 3.0,
        function: String = #function
    ) async {
        var actual = [SnackBarAction]()
        let expectedCount = expectedActions.count
        
        // Create a continuation to wait for all expected actions
        await withCheckedContinuation { continuation in
            // Listen for actions dispatched from subscriber into the redux store
            mockStore.lastDispatchedAction
                .compactMap { $0 }
                .sink { action in
                    actual.append(action)
                    
                    // Check if we've received all expected actions
                    if actual.count >= expectedCount {
                        continuation.resume()
                    }
                }
                .store(in: &suscriptions)
            
            /*
             Call subscriber (system under test), inject mock store dependancy,
             subscriber function observes environment subscriptions,
             allowing the environment to dispatch actions into the redux system
             */
            snackBarSubscriber(mockStore, mockEnvironment)
            
            setup()
            
            // Add a timeout to prevent hanging if not all actions are received
            Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                if actual.count < expectedCount {
                    continuation.resume()
                }
            }
        }
        
        // Verify the actions
        let expectedNotInActual = expectedActions.filter { !actual.contains($0) }
        #expect(expectedNotInActual.isEmpty == true, "expected is missing:\n\(expectedNotInActual).")
    }

    func expectedActions_allValues() -> [SnackBarAction] {
        // Expected values
        let type = SnackBarType.none
        mockEnvironment.snackbarStatus = .init(type)

        // Ordered array of actions expected to be dispatched into the mock store by the homeSubscriber
        return [
            .setType(type)
        ]
    }
}

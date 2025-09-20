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
@testable import Subscription
@testable import SubscriptionMocks

// MARK: - SubscriptionSubscriberTests

@MainActor
final class SubscriptionSubscriberTests {
    var mockEnvironment: MockSubscriptionEnvironment!
    var mockStore: MockStore<SubscriptionState, SubscriptionAction, SubscriptionEnvironmentProtocol>!
    var suscriptions: Set<AnyCancellable> = []

    init() {
        mockEnvironment = MockSubscriptionEnvironment()

        mockStore = MockStore(
            initial: .init(),
            reducer: subscriptionReducer,
            environment: mockEnvironment,
            middleware: subscriptionMiddleware
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

        let duplicateAction = SubscriptionAction.refreshAppSettings(.arrange)

        expectedActions.append(duplicateAction)

        await assertDispatchedActions(expectedActions) {
            self.mockEnvironment.settingsUpdatedSubject.send(.arrange)
        }
    }

    // MARK: - Assert

    func assertDispatchedActions(
        _ expectedActions: [SubscriptionAction],
        afterSetup setup: () -> Void = { /* no need to implementation */ },
        timeout: TimeInterval = 3.0,
        function: String = #function
    ) async {
        var actual = [SubscriptionAction]()
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
            subscriptionSubscriber(mockStore, mockEnvironment)
            
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

    func expectedActions_allValues() -> [SubscriptionAction] {
        // Expected values
        let settings = SettingsState.arrange
        let characterCount = 100
        mockEnvironment.settingsUpdatedSubject = .init(settings)
        mockEnvironment.synthesizedCharactersSubject = .init(characterCount)

        // Ordered array of actions expected to be dispatched into the mock store by the homeSubscriber
        return [
            .refreshAppSettings(settings),
            .trackSsmlCharacterCount(characterCount)
        ]
    }
}

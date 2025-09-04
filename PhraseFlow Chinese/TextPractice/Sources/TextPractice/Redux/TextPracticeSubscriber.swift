//
//  TextPracticeSubscriber.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 04/09/2025.
//

import Foundation
import ReduxKit

@MainActor
let textPracticeSubscriber: OnSubscribe<TextPracticeStore, TextPracticeEnvironmentProtocol> = { store, environment in

    environment.chapterSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] chapter in
                guard let store else {
                    return
                }
                store.dispatch(.setChapter(chapter))
            }
            .store(in: &store.subscriptions)

    environment.definitionsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] definitions in
                guard let store,
                let definitions,
                      !definitions.isEmpty else {
                    return
                }
                store.dispatch(.addDefinitions(definitions))
            }
            .store(in: &store.subscriptions)
}

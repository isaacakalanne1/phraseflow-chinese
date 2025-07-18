//
//  ViewStateEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import Loading

class ViewStateEnvironment: ViewStateEnvironmentProtocol {
    let isDefiningSubject = CurrentValueSubject<Bool, Never>(false)
    let loadingStateSubject = CurrentValueSubject<LoadingState, Never>(LoadingState())
    let isWritingChapterSubject = CurrentValueSubject<Bool, Never>(false)
    let definitionViewIdSubject = CurrentValueSubject<UUID, Never>(UUID())
    
    func setIsDefining(_ isDefining: Bool) {
        isDefiningSubject.send(isDefining)
    }
    
    func setLoadingState(_ state: LoadingState) {
        loadingStateSubject.send(state)
    }
    
    func setIsWritingChapter(_ isWriting: Bool) {
        isWritingChapterSubject.send(isWriting)
    }
    
    func refreshDefinitionView() {
        definitionViewIdSubject.send(UUID())
    }
}
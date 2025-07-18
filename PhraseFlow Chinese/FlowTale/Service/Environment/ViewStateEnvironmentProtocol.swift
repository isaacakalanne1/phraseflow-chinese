//
//  ViewStateEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import Loading

protocol ViewStateEnvironmentProtocol {
    var isDefiningSubject: CurrentValueSubject<Bool, Never> { get }
    var loadingStateSubject: CurrentValueSubject<LoadingState, Never> { get }
    var isWritingChapterSubject: CurrentValueSubject<Bool, Never> { get }
    var definitionViewIdSubject: CurrentValueSubject<UUID, Never> { get }
    
    func setIsDefining(_ isDefining: Bool)
    func setLoadingState(_ state: LoadingState)
    func setIsWritingChapter(_ isWriting: Bool)
    func refreshDefinitionView()
}
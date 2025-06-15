//
//  FlowTaleDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Combine
import Foundation

protocol FlowTaleDataStoreProtocol: DefinitionDataStoreProtocol,
                                    UserLimitsDataStoreProtocol,
                                    StoryDataStoreProtocol,
                                    SettingsDataStoreProtocol { }

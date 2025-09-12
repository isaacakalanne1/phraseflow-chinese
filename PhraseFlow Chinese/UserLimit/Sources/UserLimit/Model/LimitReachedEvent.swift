//
//  LimitReachedEvent.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 12/09/2025.
//

import Foundation

public enum LimitReachedEvent {
    case freeLimit
    case dailyLimit(nextAvailable: String)
}

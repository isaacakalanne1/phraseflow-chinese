//
//  UserLimitRootView.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 13/09/2025.
//

import SwiftUI

public struct UserLimitRootView: View {
    let remainingCharacters: Int
    let totalLimit: Int
    let isSubscribedUser: Bool
    let timeUntilReset: String?
    
    public init(
        remainingCharacters: Int,
        totalLimit: Int,
        isSubscribedUser: Bool,
        timeUntilReset: String?
    ) {
        self.remainingCharacters = remainingCharacters
        self.totalLimit = totalLimit
        self.isSubscribedUser = isSubscribedUser
        self.timeUntilReset = timeUntilReset
    }
    
    public var body: some View {
        UserLimitView(
            remainingCharacters: remainingCharacters,
            totalLimit: totalLimit,
            isSubscribedUser: isSubscribedUser,
            timeUntilReset: timeUntilReset
        )
    }
}

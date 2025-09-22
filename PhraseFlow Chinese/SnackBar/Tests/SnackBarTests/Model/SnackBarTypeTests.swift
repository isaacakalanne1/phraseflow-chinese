//
//  SnackBarTypeTests.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
import SwiftUI
import FTColor
@testable import SnackBar

final class SnackBarTypeTests {
    
    @Test
    func welcomeBack() {
        let type = SnackBarType.welcomeBack
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "🔥")
        #expect(type.isError == false)
        #expect(type.backgroundColor == FTColor.accent.color)
    }
    
    @Test
    func deletedCustomStory() {
        let type = SnackBarType.deletedCustomStory
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "✅")
        #expect(type.isError == false)
        #expect(type.backgroundColor == FTColor.accent.color)
    }
    
    @Test
    func subscribed() {
        let type = SnackBarType.subscribed
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "✅")
        #expect(type.isError == false)
        #expect(type.backgroundColor == FTColor.accent.color)
    }
    
    @Test
    func failedToWriteChapter() {
        let type = SnackBarType.failedToWriteChapter
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "⚠️")
        #expect(type.isError == true)
        #expect(type.backgroundColor == FTColor.error.color)
    }
    
    @Test
    func failedToSubscribe() {
        let type = SnackBarType.failedToSubscribe
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "⚠️")
        #expect(type.isError == true)
        #expect(type.backgroundColor == FTColor.error.color)
    }
    
    @Test
    func failedToWriteTranslation() {
        let type = SnackBarType.failedToWriteTranslation
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "⚠️")
        #expect(type.isError == true)
        #expect(type.backgroundColor == FTColor.error.color)
    }
    
    @Test
    func moderatingText() {
        let type = SnackBarType.moderatingText
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "⌛")
        #expect(type.isError == false)
        #expect(type.backgroundColor == FTColor.accent.color)
    }
    
    @Test
    func passedModeration() {
        let type = SnackBarType.passedModeration
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "✅")
        #expect(type.isError == false)
        #expect(type.backgroundColor == FTColor.accent.color)
    }
    
    @Test
    func couldNotModerateText() {
        let type = SnackBarType.couldNotModerateText
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "⚠️")
        #expect(type.isError == true)
        #expect(type.backgroundColor == FTColor.error.color)
    }
    
    @Test
    func didNotPassModeration() {
        let type = SnackBarType.didNotPassModeration
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji == "⚠️")
        #expect(type.isError == true)
        #expect(type.backgroundColor == FTColor.error.color)
    }
    
    @Test
    func dailyChapterLimitReached() {
        let nextAvailable = "Tomorrow at 9:00 AM"
        let type = SnackBarType.dailyChapterLimitReached(nextAvailable: nextAvailable)
        
        #expect(!type.text.isEmpty)
        #expect(type.text.contains(nextAvailable))
        #expect(type.showDuration == 4)
        #expect(type.emoji == "⌛")
        #expect(type.isError == false)
        #expect(type.backgroundColor == FTColor.accent.color)
    }
    
    @Test
    func dailyChapterLimitReached_differentTimes() {
        let type1 = SnackBarType.dailyChapterLimitReached(nextAvailable: "Tomorrow")
        let type2 = SnackBarType.dailyChapterLimitReached(nextAvailable: "Next Week")
        
        #expect(type1 != type2)
        #expect(type1.text != type2.text)
    }
    
    @Test
    func deviceVolumeZero() {
        let type = SnackBarType.deviceVolumeZero
        
        #expect(!type.text.isEmpty)
        #expect(type.showDuration == 5.0)
        #expect(type.emoji == "🔇")
        #expect(type.isError == false)
        #expect(type.backgroundColor == FTColor.accent.color)
    }
    
    @Test
    func none() {
        let type = SnackBarType.none
        
        #expect(type.text.isEmpty)
        #expect(type.showDuration == 2)
        #expect(type.emoji.isEmpty)
        #expect(type.isError == false)
        #expect(type.backgroundColor == FTColor.accent.color)
    }
    
    @Test
    func equatable() {
        #expect(SnackBarType.welcomeBack == SnackBarType.welcomeBack)
        #expect(SnackBarType.none == SnackBarType.none)
        #expect(SnackBarType.dailyChapterLimitReached(nextAvailable: "Tomorrow") == SnackBarType.dailyChapterLimitReached(nextAvailable: "Tomorrow"))
        #expect(SnackBarType.dailyChapterLimitReached(nextAvailable: "Tomorrow") != SnackBarType.dailyChapterLimitReached(nextAvailable: "Today"))
    }
}

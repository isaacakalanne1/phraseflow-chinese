//
//  ContentTabTests.swift
//  Navigation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import AppleIcon
import Localization
@testable import Navigation
@testable import NavigationMocks

class ContentTabTests {
    
    @Test
    func reader_allProperties() {
        let tab = ContentTab.reader
        
        // Test id
        #expect(tab.id == "reader")
        
        // Test title
        #expect(tab.title == LocalizedString.read)
        #expect(!tab.title.isEmpty)
        
        // Test images
        let selectedImage = tab.image(isSelected: true)
        let unselectedImage = tab.image(isSelected: false)
        #expect(selectedImage == .book(isSelected: true))
        #expect(unselectedImage == .book(isSelected: false))
        #expect(selectedImage != unselectedImage)
        
        // Test equatable
        #expect(tab == .reader)
        #expect(tab != .progress)
        #expect(tab != .translate)
        #expect(tab != .subscribe)
        #expect(tab != .settings)
        
        // Test hashable
        #expect(tab.hashValue == ContentTab.reader.hashValue)
        
        // Test it's in allCases
        #expect(ContentTab.allCases.contains(tab))
    }
    
    @Test
    func progress_allProperties() {
        let tab = ContentTab.progress
        
        // Test id
        #expect(tab.id == "progress")
        
        // Test title
        #expect(tab.title == LocalizedString.progress)
        #expect(!tab.title.isEmpty)
        
        // Test images
        let selectedImage = tab.image(isSelected: true)
        let unselectedImage = tab.image(isSelected: false)
        #expect(selectedImage == .chartLine(isSelected: true))
        #expect(unselectedImage == .chartLine(isSelected: false))
        #expect(selectedImage != unselectedImage)
        
        // Test equatable
        #expect(tab == .progress)
        #expect(tab != .reader)
        #expect(tab != .translate)
        #expect(tab != .subscribe)
        #expect(tab != .settings)
        
        // Test hashable
        #expect(tab.hashValue == ContentTab.progress.hashValue)
        
        // Test it's in allCases
        #expect(ContentTab.allCases.contains(tab))
    }
    
    @Test
    func translate_allProperties() {
        let tab = ContentTab.translate
        
        // Test id
        #expect(tab.id == "translate")
        
        // Test title
        #expect(tab.title == LocalizedString.translate)
        #expect(!tab.title.isEmpty)
        
        // Test images
        let selectedImage = tab.image(isSelected: true)
        let unselectedImage = tab.image(isSelected: false)
        #expect(selectedImage == .translate(isSelected: true))
        #expect(unselectedImage == .translate(isSelected: false))
        #expect(selectedImage != unselectedImage)
        
        // Test equatable
        #expect(tab == .translate)
        #expect(tab != .reader)
        #expect(tab != .progress)
        #expect(tab != .subscribe)
        #expect(tab != .settings)
        
        // Test hashable
        #expect(tab.hashValue == ContentTab.translate.hashValue)
        
        // Test it's in allCases
        #expect(ContentTab.allCases.contains(tab))
    }
    
    @Test
    func subscribe_allProperties() {
        let tab = ContentTab.subscribe
        
        // Test id
        #expect(tab.id == "subscribe")
        
        // Test title
        #expect(tab.title == LocalizedString.subscribe)
        #expect(!tab.title.isEmpty)
        
        // Test images
        let selectedImage = tab.image(isSelected: true)
        let unselectedImage = tab.image(isSelected: false)
        #expect(selectedImage == .heart(isSelected: true))
        #expect(unselectedImage == .heart(isSelected: false))
        #expect(selectedImage != unselectedImage)
        
        // Test equatable
        #expect(tab == .subscribe)
        #expect(tab != .reader)
        #expect(tab != .progress)
        #expect(tab != .translate)
        #expect(tab != .settings)
        
        // Test hashable
        #expect(tab.hashValue == ContentTab.subscribe.hashValue)
        
        // Test it's in allCases
        #expect(ContentTab.allCases.contains(tab))
    }
    
    @Test
    func settings_allProperties() {
        let tab = ContentTab.settings
        
        // Test id
        #expect(tab.id == "settings")
        
        // Test title
        #expect(tab.title == LocalizedString.settings)
        #expect(!tab.title.isEmpty)
        
        // Test images
        let selectedImage = tab.image(isSelected: true)
        let unselectedImage = tab.image(isSelected: false)
        #expect(selectedImage == .gear(isSelected: true))
        #expect(unselectedImage == .gear(isSelected: false))
        #expect(selectedImage != unselectedImage)
        
        // Test equatable
        #expect(tab == .settings)
        #expect(tab != .reader)
        #expect(tab != .progress)
        #expect(tab != .translate)
        #expect(tab != .subscribe)
        
        // Test hashable
        #expect(tab.hashValue == ContentTab.settings.hashValue)
        
        // Test it's in allCases
        #expect(ContentTab.allCases.contains(tab))
    }
    
    @Test
    func allCases_properties() {
        let allCases = ContentTab.allCases
        
        // Test count
        #expect(allCases.count == 5)
        
        // Test contains all expected tabs
        #expect(allCases.contains(.reader))
        #expect(allCases.contains(.progress))
        #expect(allCases.contains(.translate))
        #expect(allCases.contains(.subscribe))
        #expect(allCases.contains(.settings))
        
        // Test order is stable
        let firstAllCases = Array(ContentTab.allCases)
        let secondAllCases = Array(ContentTab.allCases)
        #expect(firstAllCases == secondAllCases)
        
        // Test all IDs are unique
        let ids = allCases.map { $0.id }
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
        
        // Test all titles are non-empty
        for tab in allCases {
            #expect(!tab.title.isEmpty)
        }
        
        // Test all tabs respond to selection state
        for tab in allCases {
            let selected = tab.image(isSelected: true)
            let unselected = tab.image(isSelected: false)
            #expect(selected != unselected)
        }
    }
    
    @Test
    func hashable_usage() {
        // Test can be used in Set
        let tabSet: Set<ContentTab> = [.reader, .progress, .reader, .translate]
        #expect(tabSet.count == 3) // Duplicate .reader removed
        #expect(tabSet.contains(.reader))
        #expect(tabSet.contains(.progress))
        #expect(tabSet.contains(.translate))
        #expect(!tabSet.contains(.subscribe))
        #expect(!tabSet.contains(.settings))
        
        // Test can be used as Dictionary key
        let tabDict: [ContentTab: String] = [
            .reader: "Read content",
            .progress: "Track progress",
            .translate: "Translate text"
        ]
        #expect(tabDict[.reader] == "Read content")
        #expect(tabDict[.progress] == "Track progress")
        #expect(tabDict[.translate] == "Translate text")
        #expect(tabDict[.subscribe] == nil)
        #expect(tabDict[.settings] == nil)
    }
    
    @Test(arguments: ContentTab.allCases)
    func identifiable_consistency(tab: ContentTab) {
        // Test id is consistent
        let firstId = tab.id
        let secondId = tab.id
        let thirdId = tab.id
        
        #expect(firstId == secondId)
        #expect(secondId == thirdId)
        #expect(!firstId.isEmpty)
        
        // Test id matches expected pattern
        switch tab {
        case .reader:
            #expect(tab.id == "reader")
        case .progress:
            #expect(tab.id == "progress")
        case .translate:
            #expect(tab.id == "translate")
        case .subscribe:
            #expect(tab.id == "subscribe")
        case .settings:
            #expect(tab.id == "settings")
        }
    }
}
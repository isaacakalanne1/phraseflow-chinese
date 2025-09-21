//
//  NavigationReducerTests.swift
//  Navigation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Settings
import SettingsMocks
@testable import Navigation
@testable import NavigationMocks

final class NavigationReducerTests {
    
    @Test
    func selectTab_updatesContentTab() {
        let initialState = NavigationState.arrange(contentTab: .reader)
        var expectedState = initialState
        expectedState.contentTab = .progress
        
        let newState = navigationReducer(
            initialState,
            .selectTab(.progress)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test(arguments: ContentTab.allCases)
    func selectTab_allTabs_updatesContentTab(tab: ContentTab) {
        let initialState = NavigationState.arrange(contentTab: .reader)
        var expectedState = initialState
        expectedState.contentTab = tab
        
        let newState = navigationReducer(
            initialState,
            .selectTab(tab)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func selectTab_fromAnyTabToAnyTab() {
        let tabTransitions: [(from: ContentTab, to: ContentTab)] = [
            (.reader, .progress),
            (.progress, .translate),
            (.translate, .subscribe),
            (.subscribe, .settings),
            (.settings, .reader)
        ]
        
        for transition in tabTransitions {
            let initialState = NavigationState.arrange(contentTab: transition.from)
            var expectedState = initialState
            expectedState.contentTab = transition.to
            
            let newState = navigationReducer(
                initialState,
                .selectTab(transition.to)
            )
            
            #expect(newState == expectedState)
        }
    }
    
    @Test
    func selectTab_sameTab_stillUpdates() {
        let tab = ContentTab.settings
        let initialState = NavigationState.arrange(contentTab: tab)
        var expectedState = initialState
        expectedState.contentTab = tab
        
        let newState = navigationReducer(
            initialState,
            .selectTab(tab)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func refreshAppSettings_updatesSettings() {
        let initialSettings = SettingsState.arrange(voice: .elvira)
        let updatedSettings = SettingsState.arrange(
            isShowingDefinition: false,
            voice: .denise,
            difficulty: .advanced
        )
        
        let initialState = NavigationState.arrange(settings: initialSettings)
        var expectedState = initialState
        expectedState.settings = updatedSettings
        
        let newState = navigationReducer(
            initialState,
            .refreshAppSettings(updatedSettings)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func refreshAppSettings_completelyReplacesSettings() {
        let initialSettings = SettingsState.arrange(
            isShowingDefinition: true,
            isShowingEnglish: true,
            isPlayingMusic: false,
            voice: .elvira,
            difficulty: .beginner,
            language: .spanish,
            shouldPlaySound: false
        )
        
        let newSettings = SettingsState.arrange(
            isShowingDefinition: false,
            isShowingEnglish: false,
            isPlayingMusic: true,
            voice: .xiaoxiao,
            difficulty: .advanced,
            language: .mandarinChinese,
            shouldPlaySound: true
        )
        
        let initialState = NavigationState.arrange(settings: initialSettings)
        var expectedState = initialState
        expectedState.settings = newSettings
        
        let newState = navigationReducer(
            initialState,
            .refreshAppSettings(newSettings)
        )
        
        #expect(newState == expectedState)
        #expect(newState.settings.isShowingDefinition == false)
        #expect(newState.settings.isShowingEnglish == false)
        #expect(newState.settings.voice == .xiaoxiao)
        #expect(newState.settings.difficulty == .advanced)
        #expect(newState.settings.language == .mandarinChinese)
        #expect(newState.settings.shouldPlaySound == true)
        #expect(newState.settings.isPlayingMusic == true)
    }
    
    @Test
    func refreshAppSettings_doesNotAffectContentTab() {
        let tab = ContentTab.translate
        let newSettings = SettingsState.arrange()
        
        let initialState = NavigationState.arrange(
            contentTab: tab,
            settings: .arrange(voice: .elvira)
        )
        
        let newState = navigationReducer(
            initialState,
            .refreshAppSettings(newSettings)
        )
        
        #expect(newState.contentTab == tab)
    }
    
    @Test
    func multipleActions_applyCorrectly() {
        var state = NavigationState.arrange(contentTab: .reader)
        
        // First action: select progress tab
        state = navigationReducer(state, .selectTab(.progress))
        #expect(state.contentTab == .progress)
        
        // Second action: refresh settings
        let newSettings = SettingsState.arrange(voice: .denise)
        state = navigationReducer(state, .refreshAppSettings(newSettings))
        #expect(state.contentTab == .progress) // Tab should remain
        #expect(state.settings.voice == .denise)
        
        // Third action: select another tab
        state = navigationReducer(state, .selectTab(.settings))
        #expect(state.contentTab == .settings)
        #expect(state.settings.voice == .denise) // Settings should remain
    }
}

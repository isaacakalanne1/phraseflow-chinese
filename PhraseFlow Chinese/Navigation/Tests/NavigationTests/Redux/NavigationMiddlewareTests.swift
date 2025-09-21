//
//  NavigationMiddlewareTests.swift
//  Navigation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Audio
import Settings
import SettingsMocks
@testable import Navigation
@testable import NavigationMocks

final class NavigationMiddlewareTests {
    
    let mockEnvironment: MockNavigationEnvironment
    
    init() {
        mockEnvironment = MockNavigationEnvironment()
    }
    
    @Test
    func selectTab_whenSoundEnabled_playsTabPressSound() async {
        let state: NavigationState = .arrange(settings: .arrange(shouldPlaySound: true))
        
        let resultAction = await navigationMiddleware(
            state,
            .selectTab(.progress),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == .tabPress)
    }
    
    @Test
    func selectTab_whenSoundDisabled_doesNotPlaySound() async {
        let state: NavigationState = .arrange(settings: .arrange(shouldPlaySound: false))
        
        let resultAction = await navigationMiddleware(
            state,
            .selectTab(.settings),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test(arguments: ContentTab.allCases)
    func selectTab_allTabs_whenSoundEnabled_playsTabPressSound(tab: ContentTab) async {
        let state: NavigationState = .arrange(settings: .arrange(shouldPlaySound: true))
        
        let resultAction = await navigationMiddleware(
            state,
            .selectTab(tab),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == .tabPress)
    }
    
    @Test(arguments: ContentTab.allCases)
    func selectTab_allTabs_whenSoundDisabled_doesNotPlaySound(tab: ContentTab) async {
        let state: NavigationState = .arrange(settings: .arrange(shouldPlaySound: false))
        
        let resultAction = await navigationMiddleware(
            state,
            .selectTab(tab),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func refreshAppSettings_returnsNil() async {
        let settings: SettingsState = .arrange
        
        let resultAction = await navigationMiddleware(
            .arrange,
            .refreshAppSettings(settings),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == false)
    }
}

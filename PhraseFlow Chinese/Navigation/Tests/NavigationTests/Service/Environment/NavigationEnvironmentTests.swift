//
//  NavigationEnvironmentTests.swift
//  Navigation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Combine
import Audio
@testable import AudioMocks
import LoadingMocks
import Settings
import SettingsMocks
import StoryMocks
import StudyMocks
import SubscriptionMocks
import TranslationMocks
import UserLimitMocks
@testable import Navigation
@testable import NavigationMocks

class NavigationEnvironmentTests {
    let environment: NavigationEnvironmentProtocol
    let mockSettingsEnvironment: MockSettingsEnvironment
    let mockStoryEnvironment: MockStoryEnvironment
    let mockStudyEnvironment: MockStudyEnvironment
    let mockSubscriptionEnvironment: MockSubscriptionEnvironment
    let mockTranslationEnvironment: MockTranslationEnvironment
    let mockUserLimitEnvironment: MockUserLimitEnvironment
    let mockAudioEnvironment: MockAudioEnvironment
    let mockLoadingEnvironment: MockLoadingEnvironment
    
    init() {
        self.mockSettingsEnvironment = MockSettingsEnvironment()
        self.mockStoryEnvironment = MockStoryEnvironment()
        self.mockStudyEnvironment = MockStudyEnvironment()
        self.mockSubscriptionEnvironment = MockSubscriptionEnvironment()
        self.mockTranslationEnvironment = MockTranslationEnvironment()
        self.mockUserLimitEnvironment = MockUserLimitEnvironment()
        self.mockAudioEnvironment = MockAudioEnvironment()
        self.mockLoadingEnvironment = MockLoadingEnvironment()
        
        self.environment = NavigationEnvironment(
            settingsEnvironment: mockSettingsEnvironment,
            storyEnvironment: mockStoryEnvironment,
            studyEnvironment: mockStudyEnvironment,
            subscriptionEnvironment: mockSubscriptionEnvironment,
            translationEnvironment: mockTranslationEnvironment,
            userLimitEnvironment: mockUserLimitEnvironment,
            audioEnvironment: mockAudioEnvironment,
            loadingEnvironment: mockLoadingEnvironment
        )
    }
    
    @Test
    func playSound_delegatesToAudioEnvironment() {
        let sound = AppSound.actionButtonPress
        
        environment.playSound(sound)
        
        #expect(mockAudioEnvironment.playSoundCalled == true)
        #expect(mockAudioEnvironment.playSoundSpy == sound)
    }
    
    @Test(arguments: [
        AppSound.actionButtonPress,
        AppSound.tabPress,
        AppSound.togglePress
    ])
    func playSound_variousSounds_delegatesToAudioEnvironment(sound: AppSound) {
        environment.playSound(sound)
        
        #expect(mockAudioEnvironment.playSoundCalled == true)
        #expect(mockAudioEnvironment.playSoundSpy == sound)
    }
    
    @Test
    func settingsUpdatedSubject_returnsSettingsEnvironmentSubject() {
        let expectedSettings = SettingsState.arrange
        mockSettingsEnvironment.settingsUpdatedSubject.send(expectedSettings)
        
        #expect(environment.settingsUpdatedSubject.value == expectedSettings)
    }
    
    @Test
    func settingsUpdatedSubject_propagatesChanges() {
        let initialSettings = SettingsState.arrange(voice: .elvira)
        let updatedSettings = SettingsState.arrange(voice: .denise)
        
        mockSettingsEnvironment.settingsUpdatedSubject.send(initialSettings)
        #expect(environment.settingsUpdatedSubject.value == initialSettings)
        
        mockSettingsEnvironment.settingsUpdatedSubject.send(updatedSettings)
        #expect(environment.settingsUpdatedSubject.value == updatedSettings)
    }
    
    @Test
    func settingsUpdatedSubject_startsWithNil() {
        #expect(environment.settingsUpdatedSubject.value == nil)
    }
}

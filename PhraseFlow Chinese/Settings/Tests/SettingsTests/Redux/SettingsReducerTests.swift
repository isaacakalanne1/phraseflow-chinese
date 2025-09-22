import Testing
@testable import Settings
@testable import SettingsMocks
@testable import Moderation
@testable import ModerationMocks

final class SettingsReducerTests {
    
    @Test
    func loadAppSettings() {
        let state = SettingsState.arrange

        let newState = settingsReducer(
            state,
            .loadAppSettings
        )

        #expect(newState == state)
    }
    
    @Test
    func onLoadedAppSettings() {
        let initialState = SettingsState.arrange
        let expectedSettings = SettingsState.arrange(customPrompts: ["a", "b", "c"])
        let expectedState = expectedSettings

        let newState = settingsReducer(
            initialState,
            .onLoadedAppSettings(expectedSettings)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateShowDefinition_true() {
        let initialState = SettingsState.arrange
        let expectedIsShowing = true
        
        var expectedState = initialState
        expectedState.isShowingDefinition = expectedIsShowing

        let newState = settingsReducer(
            initialState,
            .updateShowDefinition(expectedIsShowing)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateShowDefinition_false() {
        let initialState = SettingsState.arrange
        let expectedIsShowing = false
        
        var expectedState = initialState
        expectedState.isShowingDefinition = expectedIsShowing

        let newState = settingsReducer(
            initialState,
            .updateShowDefinition(expectedIsShowing)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func failedToLoadAppSettings_doesNotChangeState() {
        let state = SettingsState.arrange(usedCharacters: 999)

        let newState = settingsReducer(
            state,
            .failedToLoadAppSettings
        )

        #expect(newState == state)
    }
    
    @Test
    func refreshAppSettings_updatesEntireState() {
        let initialState = SettingsState.arrange
        let refreshedSettings = SettingsState.arrange(
            isShowingDefinition: false,
            isShowingEnglish: false,
            voice: .denise,
            usedCharacters: 1000
        )

        let newState = settingsReducer(
            initialState,
            .refreshAppSettings(refreshedSettings)
        )

        #expect(newState == refreshedSettings)
    }
    
    @Test
    func saveAppSettings_doesNotChangeState() {
        let state = SettingsState.arrange(usedCharacters: 123)

        let newState = settingsReducer(
            state,
            .saveAppSettings
        )

        #expect(newState == state)
    }
    
    @Test
    func failedToSaveAppSettings_doesNotChangeState() {
        let state = SettingsState.arrange

        let newState = settingsReducer(
            state,
            .failedToSaveAppSettings
        )

        #expect(newState == state)
    }
    
    @Test
    func updateShowEnglish_true() {
        let initialState = SettingsState.arrange(isShowingEnglish: false)
        var expectedState = initialState
        expectedState.isShowingEnglish = true

        let newState = settingsReducer(
            initialState,
            .updateShowEnglish(true)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateShowEnglish_false() {
        let initialState = SettingsState.arrange(isShowingEnglish: true)
        var expectedState = initialState
        expectedState.isShowingEnglish = false

        let newState = settingsReducer(
            initialState,
            .updateShowEnglish(false)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func selectVoice_updatesVoice() {
        let initialState = SettingsState.arrange(voice: .elvira)
        var expectedState = initialState
        expectedState.voice = .denise

        let newState = settingsReducer(
            initialState,
            .selectVoice(.denise)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateDifficulty_beginner() {
        let initialState = SettingsState.arrange(difficulty: .intermediate)
        var expectedState = initialState
        expectedState.difficulty = .beginner

        let newState = settingsReducer(
            initialState,
            .updateDifficulty(.beginner)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateDifficulty_intermediate() {
        let initialState = SettingsState.arrange(difficulty: .beginner)
        var expectedState = initialState
        expectedState.difficulty = .intermediate

        let newState = settingsReducer(
            initialState,
            .updateDifficulty(.intermediate)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateDifficulty_advanced() {
        let initialState = SettingsState.arrange(difficulty: .beginner)
        var expectedState = initialState
        expectedState.difficulty = .advanced

        let newState = settingsReducer(
            initialState,
            .updateDifficulty(.advanced)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateLanguage_changesLanguageAndVoice() {
        let initialState = SettingsState.arrange()
        var expectedState = initialState
        expectedState.language = .mandarinChinese
        expectedState.voice = .xiaoxiao

        let newState = settingsReducer(
            initialState,
            .updateLanguage(.mandarinChinese)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateLanguage_sameLanguage_doesNotChangeVoice() {
        let initialState = SettingsState.arrange(
            voice: .elvira,
            language: .spanish
        )
        
        let newState = settingsReducer(
            initialState,
            .updateLanguage(.spanish)
        )

        #expect(newState == initialState)
        #expect(newState.voice == .elvira)
    }
    
    @Test
    func updateCustomPrompt() {
        let initialState = SettingsState.arrange(customPrompt: "old prompt")
        var expectedState = initialState
        expectedState.customPrompt = "new prompt"

        let newState = settingsReducer(
            initialState,
            .updateCustomPrompt("new prompt")
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateStorySetting_toRandom() {
        let initialState = SettingsState.arrange(storySetting: .customPrompt("test"))
        var expectedState = initialState
        expectedState.storySetting = .random

        let newState = settingsReducer(
            initialState,
            .updateStorySetting(.random)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateStorySetting_toNewCustomPrompt_addsToList() {
        let newPrompt = "A story about dragons"
        let initialState = SettingsState.arrange(
            storySetting: .random,
            customPrompts: ["existing prompt"]
        )
        var expectedState = initialState
        expectedState.storySetting = .customPrompt(newPrompt)
        expectedState.customPrompts = ["existing prompt", newPrompt]

        let newState = settingsReducer(
            initialState,
            .updateStorySetting(.customPrompt(newPrompt))
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateStorySetting_toExistingCustomPrompt_doesNotDuplicate() {
        let existingPrompt = "existing prompt"
        let initialState = SettingsState.arrange(
            storySetting: .random,
            customPrompts: [existingPrompt]
        )
        var expectedState = initialState
        expectedState.storySetting = .customPrompt(existingPrompt)

        let newState = settingsReducer(
            initialState,
            .updateStorySetting(.customPrompt(existingPrompt))
        )

        #expect(newState == expectedState)
        #expect(newState.customPrompts.count == 1)
    }
    
    @Test
    func updateIsShowingCustomPromptAlert_true() {
        let initialState = SettingsState.arrange(isShowingCustomPromptAlert: false)
        var expectedState = initialState
        expectedState.isShowingCustomPromptAlert = true

        let newState = settingsReducer(
            initialState,
            .updateIsShowingCustomPromptAlert(true)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateIsShowingCustomPromptAlert_false() {
        let initialState = SettingsState.arrange(isShowingCustomPromptAlert: true)
        var expectedState = initialState
        expectedState.isShowingCustomPromptAlert = false

        let newState = settingsReducer(
            initialState,
            .updateIsShowingCustomPromptAlert(false)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func deleteCustomPrompt_removesFromList() {
        let promptToDelete = "prompt to delete"
        let initialState = SettingsState.arrange(
            storySetting: .random,
            customPrompts: ["keep this", promptToDelete, "keep this too"]
        )
        var expectedState = initialState
        expectedState.customPrompts = ["keep this", "keep this too"]

        let newState = settingsReducer(
            initialState,
            .deleteCustomPrompt(promptToDelete)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func deleteCustomPrompt_whenCurrentlySelected_switchesToRandom() {
        let promptToDelete = "current prompt"
        let initialState = SettingsState.arrange(
            storySetting: .customPrompt(promptToDelete),
            customPrompts: [promptToDelete, "other prompt"]
        )
        var expectedState = initialState
        expectedState.storySetting = .random
        expectedState.customPrompts = ["other prompt"]

        let newState = settingsReducer(
            initialState,
            .deleteCustomPrompt(promptToDelete)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateShouldPlaySound_true() {
        let initialState = SettingsState.arrange(shouldPlaySound: false)
        var expectedState = initialState
        expectedState.shouldPlaySound = true

        let newState = settingsReducer(
            initialState,
            .updateShouldPlaySound(true)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateShouldPlaySound_false() {
        let initialState = SettingsState.arrange(shouldPlaySound: true)
        var expectedState = initialState
        expectedState.shouldPlaySound = false

        let newState = settingsReducer(
            initialState,
            .updateShouldPlaySound(false)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateIsShowingModerationFailedAlert_true() {
        let initialState = SettingsState.arrange(isShowingModerationFailedAlert: false)
        var expectedState = initialState
        expectedState.isShowingModerationFailedAlert = true

        let newState = settingsReducer(
            initialState,
            .updateIsShowingModerationFailedAlert(true)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateIsShowingModerationFailedAlert_false() {
        let initialState = SettingsState.arrange(isShowingModerationFailedAlert: true)
        var expectedState = initialState
        expectedState.isShowingModerationFailedAlert = false

        let newState = settingsReducer(
            initialState,
            .updateIsShowingModerationFailedAlert(false)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateIsShowingModerationDetails_true() {
        let initialState = SettingsState.arrange(
            viewState: SettingsViewState.arrange(isShowingModerationDetails: false)
        )
        var expectedState = initialState
        expectedState.viewState.isShowingModerationDetails = true

        let newState = settingsReducer(
            initialState,
            .updateIsShowingModerationDetails(true)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateIsShowingModerationDetails_false() {
        let initialState = SettingsState.arrange(
            viewState: SettingsViewState.arrange(isShowingModerationDetails: true)
        )
        var expectedState = initialState
        expectedState.viewState.isShowingModerationDetails = false

        let newState = settingsReducer(
            initialState,
            .updateIsShowingModerationDetails(false)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateModerationResponse_withResponse() {
        let response = ModerationResponse.arrange()
        let initialState = SettingsState.arrange(
            viewState: SettingsViewState.arrange(moderationResponse: nil)
        )
        var expectedState = initialState
        expectedState.viewState.moderationResponse = response

        let newState = settingsReducer(
            initialState,
            .updateModerationResponse(response)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateModerationResponse_withFailedResponse_showsAlert() {
        let failedResponse = ModerationResponse.arrange(results: [
            .arrange(category_scores: [ModerationCategories.violenceGraphic.key: 0.9])
        ])
        let initialState = SettingsState.arrange(
            isShowingModerationFailedAlert: false,
            viewState: SettingsViewState.arrange(moderationResponse: nil)
        )
        var expectedState = initialState
        expectedState.viewState.moderationResponse = failedResponse
        expectedState.isShowingModerationFailedAlert = true

        let newState = settingsReducer(
            initialState,
            .updateModerationResponse(failedResponse)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func updateModerationResponse_nil() {
        let initialState = SettingsState.arrange(
            viewState: SettingsViewState.arrange(moderationResponse: .arrange())
        )
        var expectedState = initialState
        expectedState.viewState.moderationResponse = nil

        let newState = settingsReducer(
            initialState,
            .updateModerationResponse(nil)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func playMusic_setsIsPlayingMusicTrue() {
        let initialState = SettingsState.arrange(isPlayingMusic: false)
        var expectedState = initialState
        expectedState.isPlayingMusic = true

        let newState = settingsReducer(
            initialState,
            .playMusic(.whispersOfTheForest)
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func stopMusic_setsIsPlayingMusicFalse() {
        let initialState = SettingsState.arrange(isPlayingMusic: true)
        var expectedState = initialState
        expectedState.isPlayingMusic = false

        let newState = settingsReducer(
            initialState,
            .stopMusic
        )

        #expect(newState == expectedState)
    }
    
    @Test
    func playSound_doesNotChangeState() {
        let state = SettingsState.arrange

        let newState = settingsReducer(
            state,
            .playSound(.actionButtonPress)
        )

        #expect(newState == state)
    }
    
    @Test
    func snackbarAction_doesNotChangeState() {
        let state = SettingsState.arrange

        let newState = settingsReducer(
            state,
            .snackbarAction(.setType(.none))
        )

        #expect(newState == state)
    }
    
    @Test
    func submitCustomPrompt_doesNotChangeState() {
        let state = SettingsState.arrange

        let newState = settingsReducer(
            state,
            .submitCustomPrompt("test prompt")
        )

        #expect(newState == state)
    }
}

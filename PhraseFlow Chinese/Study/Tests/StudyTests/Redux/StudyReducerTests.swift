import Testing
import AVKit
import Foundation
import Settings
import TextGeneration
@testable import Study
@testable import StudyMocks

final class StudyReducerTests {
    
    @Test
    func onPreparedStudySentence_setsSentenceAudioPlayer() {
        let newPlayer = AVPlayer()
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .onPreparedStudySentence(newPlayer)
        )
        
        #expect(newState.sentenceAudioPlayer == newPlayer)
    }
    
    @Test
    func onPreparedStudyWord_setsAudioPlayer() {
        let newPlayer = AVPlayer()
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .onPreparedStudyWord(newPlayer)
        )
        
        #expect(newState.audioPlayer == newPlayer)
    }
    
    @Test
    func failedToPrepareStudyWord_resetsAudioPlayer() {
        let existingPlayer = AVPlayer()
        let initialState = StudyState.arrange(audioPlayer: existingPlayer)
        
        let newState = studyReducer(
            initialState,
            .failedToPrepareStudyWord
        )
        
        #expect(newState.audioPlayer != existingPlayer)
        #expect(newState.audioPlayer != nil)
    }
    
    @Test
    func failedToPrepareStudySentence_resetsSentenceAudioPlayer() {
        let existingPlayer = AVPlayer()
        let initialState = StudyState.arrange(sentenceAudioPlayer: existingPlayer)
        
        let newState = studyReducer(
            initialState,
            .failedToPrepareStudySentence
        )
        
        #expect(newState.sentenceAudioPlayer != existingPlayer)
        #expect(newState.sentenceAudioPlayer != nil)
    }
    
    @Test
    func updateDisplayStatus_updatesDisplayStatus() {
        let initialState = StudyState.arrange(displayStatus: .wordShown)
        let newDisplayStatus: StudyDisplayStatus = .pronounciationShown
        
        let newState = studyReducer(
            initialState,
            .updateDisplayStatus(newDisplayStatus)
        )
        
        #expect(newState.displayStatus == newDisplayStatus)
    }
    
    @Test
    func refreshAppSettings_updatesSettings() {
        let initialSettings = SettingsState.arrange(language: .spanish)
        let newSettings = SettingsState.arrange(language: .mandarinChinese)
        let initialState = StudyState.arrange(settings: initialSettings)
        
        let newState = studyReducer(
            initialState,
            .refreshAppSettings(newSettings)
        )
        
        #expect(newState.settings == newSettings)
    }
    
    @Test
    func deleteDefinition_removesDefinitionFromList() {
        let definitionToDelete = Definition.arrange(id: UUID())
        let definitionToKeep = Definition.arrange(id: UUID())
        let initialState = StudyState.arrange(definitions: [definitionToDelete, definitionToKeep])
        
        let newState = studyReducer(
            initialState,
            .deleteDefinition(definitionToDelete)
        )
        
        #expect(newState.definitions.count == 1)
        #expect(newState.definitions[0].id == definitionToKeep.id)
        #expect(!newState.definitions.contains(where: { $0.id == definitionToDelete.id }))
    }
    
    @Test
    func deleteDefinition_whenDefinitionNotFound_doesNotChangeDefinitions() {
        let existingDefinition = Definition.arrange
        let nonExistentDefinition = Definition.arrange
        let initialState = StudyState.arrange(definitions: [existingDefinition])
        
        let newState = studyReducer(
            initialState,
            .deleteDefinition(nonExistentDefinition)
        )
        
        #expect(newState.definitions.count == 1)
        #expect(newState.definitions[0].id == existingDefinition.id)
    }
    
    @Test
    func updateStudiedWord_whenDefinitionExists_updatesExistingDefinition() {
        let timestampData = WordTimeStampData.arrange
        let existingDefinition = Definition.arrange(
            studiedDates: [],
            timestampData: timestampData
        )
        let initialState = StudyState.arrange(definitions: [existingDefinition])
        
        let updatedDefinition = existingDefinition
        
        let newState = studyReducer(
            initialState,
            .updateStudiedWord(updatedDefinition)
        )
        
        #expect(newState.definitions.count == 1)
        #expect(newState.definitions[0].timestampData == timestampData)
        #expect(newState.definitions[0].studiedDates.count == 1)
    }
    
    @Test
    func updateStudiedWord_whenDefinitionDoesNotExist_addsNewDefinition() {
        let existingDefinition = Definition.arrange(timestampData: .arrange)
        let newDefinition = Definition.arrange(
            studiedDates: [],
            timestampData: .arrange(word: "different")
        )
        let initialState = StudyState.arrange(definitions: [existingDefinition])
        
        let newState = studyReducer(
            initialState,
            .updateStudiedWord(newDefinition)
        )
        
        #expect(newState.definitions.count == 2)
        #expect(newState.definitions.contains(where: { $0.id == existingDefinition.id }))
        #expect(newState.definitions.contains(where: { $0.timestampData.word == "different" }))
        
        let addedDefinition = newState.definitions.first(where: { $0.timestampData.word == "different" })
        #expect(addedDefinition?.studiedDates.count == 1)
    }
    
    @Test
    func onLoadDefinitions_replacesAllDefinitions() {
        let existingDefinitions = [Definition.arrange, Definition.arrange]
        let newDefinitions = [Definition.arrange, Definition.arrange, Definition.arrange]
        let initialState = StudyState.arrange(definitions: existingDefinitions)
        
        let newState = studyReducer(
            initialState,
            .onLoadDefinitions(newDefinitions)
        )
        
        #expect(newState.definitions == newDefinitions)
        #expect(newState.definitions.count == 3)
    }
    
    @Test
    func onLoadDefinitions_withEmptyArray_clearsDefinitions() {
        let existingDefinitions = [Definition.arrange, Definition.arrange]
        let initialState = StudyState.arrange(definitions: existingDefinitions)
        
        let newState = studyReducer(
            initialState,
            .onLoadDefinitions([])
        )
        
        #expect(newState.definitions.isEmpty)
    }
    
    @Test
    func addDefinitions_replacesExistingDefinitionsWithSameId() {
        let definitionId = UUID()
        let existingDefinition = Definition.arrange(id: definitionId, hasBeenSeen: false)
        let updatedDefinition = Definition.arrange(id: definitionId, hasBeenSeen: true)
        let otherDefinition = Definition.arrange
        let initialState = StudyState.arrange(definitions: [existingDefinition, otherDefinition])
        
        let newState = studyReducer(
            initialState,
            .addDefinitions([updatedDefinition])
        )
        
        #expect(newState.definitions.count == 2)
        #expect(newState.definitions.contains(where: { $0.id == definitionId && $0.hasBeenSeen == true }))
        #expect(newState.definitions.contains(where: { $0.id == otherDefinition.id }))
    }
    
    @Test
    func addDefinitions_addsNewDefinitionsWithUniqueIds() {
        let existingDefinition = Definition.arrange
        let newDefinition1 = Definition.arrange
        let newDefinition2 = Definition.arrange
        let initialState = StudyState.arrange(definitions: [existingDefinition])
        
        let newState = studyReducer(
            initialState,
            .addDefinitions([newDefinition1, newDefinition2])
        )
        
        #expect(newState.definitions.count == 3)
        #expect(newState.definitions.contains(where: { $0.id == existingDefinition.id }))
        #expect(newState.definitions.contains(where: { $0.id == newDefinition1.id }))
        #expect(newState.definitions.contains(where: { $0.id == newDefinition2.id }))
    }
    
    @Test
    func addDefinitions_withEmptyArray_doesNotChangeDefinitions() {
        let existingDefinitions = [Definition.arrange, Definition.arrange]
        let initialState = StudyState.arrange(definitions: existingDefinitions)
        
        let newState = studyReducer(
            initialState,
            .addDefinitions([])
        )
        
        #expect(newState.definitions == existingDefinitions)
    }
    
    @Test
    func prepareToPlayStudySentence_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .prepareToPlayStudySentence(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func playStudySentence_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .playStudySentence
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func pauseStudyAudio_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .pauseStudyAudio
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func prepareToPlayStudyWord_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .prepareToPlayStudyWord(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func playStudyWord_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .playStudyWord
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func failedToDeleteDefinition_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .failedToDeleteDefinition
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func playSound_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .playSound(.actionButtonPress)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func loadDefinitions_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .loadDefinitions
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func failedToLoadDefinitions_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .failedToLoadDefinitions
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func saveDefinitions_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .saveDefinitions([.arrange])
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func onSavedDefinitions_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .onSavedDefinitions([.arrange])
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func failedToSaveDefinitions_doesNotChangeState() {
        let initialState = StudyState.arrange
        
        let newState = studyReducer(
            initialState,
            .failedToSaveDefinitions
        )
        
        #expect(newState == initialState)
    }
}

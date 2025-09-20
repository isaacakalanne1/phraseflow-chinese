import Testing
import Foundation
import Settings
import TextGeneration
@testable import Story
@testable import StoryMocks

final class StoryReducerTests {
    
    @Test
    func onLoadedStories_withEmptyState_groupsChaptersByStoryAndSetsCurrentChapter() {
        let storyId1 = UUID()
        let storyId2 = UUID()
        let chapter1 = Chapter.arrange(storyId: storyId1, lastUpdated: Date(timeIntervalSince1970: 100))
        let chapter2 = Chapter.arrange(storyId: storyId1, lastUpdated: Date(timeIntervalSince1970: 200))
        let chapter3 = Chapter.arrange(storyId: storyId2, lastUpdated: Date(timeIntervalSince1970: 150))
        let chapters = [chapter1, chapter2, chapter3]
        
        let initialState = StoryState.arrange(currentChapter: nil)
        
        let newState = storyReducer(
            initialState,
            .onLoadedStories(chapters)
        )
        
        #expect(newState.storyChapters[storyId1]?.count == 2)
        #expect(newState.storyChapters[storyId2]?.count == 1)
        #expect(newState.storyChapters[storyId1]?[0] == chapter1)
        #expect(newState.storyChapters[storyId1]?[1] == chapter2)
        #expect(newState.storyChapters[storyId2]?[0] == chapter3)
        #expect(newState.currentChapter == chapter2)
    }
    
    @Test
    func onLoadedStories_withExistingCurrentChapter_doesNotChangeCurrentChapter() {
        let existingChapter = Chapter.arrange
        let newChapter = Chapter.arrange
        let initialState = StoryState.arrange(currentChapter: existingChapter)
        
        let newState = storyReducer(
            initialState,
            .onLoadedStories([newChapter])
        )
        
        #expect(newState.currentChapter == existingChapter)
    }
    
    @Test
    func onLoadedStories_sortsChaptersByLastUpdated() {
        let storyId = UUID()
        let olderChapter = Chapter.arrange(storyId: storyId, lastUpdated: Date(timeIntervalSince1970: 100))
        let newerChapter = Chapter.arrange(storyId: storyId, lastUpdated: Date(timeIntervalSince1970: 200))
        let chapters = [newerChapter, olderChapter]
        
        let initialState = StoryState.arrange()
        
        let newState = storyReducer(
            initialState,
            .onLoadedStories(chapters)
        )
        
        #expect(newState.storyChapters[storyId]?[0] == olderChapter)
        #expect(newState.storyChapters[storyId]?[1] == newerChapter)
    }
    
    @Test
    func onCreatedChapter_addsChapterToStoryAndSetsAsCurrent() {
        let storyId = UUID()
        let sentence = Sentence.arrange(timestamps: [.arrange(time: 0.5)])
        let chapter = Chapter.arrange(storyId: storyId, sentences: [sentence])
        let initialState = StoryState.arrange(isWritingChapter: true)
        
        let newState = storyReducer(
            initialState,
            .onCreatedChapter(chapter)
        )
        
        #expect(newState.isWritingChapter == false)
        #expect(newState.storyChapters[storyId]?.count == 1)
        #expect(newState.storyChapters[storyId]?[0].id == chapter.id)
        #expect(newState.currentChapter?.id == chapter.id)
        #expect(newState.currentChapter?.currentSentence == sentence)
        #expect(newState.currentChapter?.currentPlaybackTime == 0.5)
    }
    
    @Test
    func onCreatedChapter_withExistingStory_appendsToExistingChapters() {
        let storyId = UUID()
        let existingChapter = Chapter.arrange(storyId: storyId)
        let newChapter = Chapter.arrange(storyId: storyId)
        let initialState = StoryState.arrange(
            storyChapters: [storyId: [existingChapter]],
            isWritingChapter: true
        )
        
        let newState = storyReducer(
            initialState,
            .onCreatedChapter(newChapter)
        )
        
        #expect(newState.storyChapters[storyId]?.count == 2)
        #expect(newState.storyChapters[storyId]?[0] == existingChapter)
        #expect(newState.storyChapters[storyId]?[1].id == newChapter.id)
        #expect(newState.currentChapter?.id == newChapter.id)
    }
    
    @Test
    func onCreatedChapter_withNoTimestamps_setsDefaultPlaybackTime() {
        let chapter = Chapter.arrange(sentences: [Sentence.arrange(timestamps: [])])
        let initialState = StoryState.arrange()
        
        let newState = storyReducer(
            initialState,
            .onCreatedChapter(chapter)
        )
        
        #expect(newState.currentChapter?.currentPlaybackTime == 0.1)
    }
    
    @Test
    func onDeletedStory_removesStoryChapters() {
        let storyId = UUID()
        let chapter = Chapter.arrange(storyId: storyId)
        let initialState = StoryState.arrange(
            storyChapters: [storyId: [chapter]]
        )
        
        let newState = storyReducer(
            initialState,
            .onDeletedStory(storyId)
        )
        
        #expect(newState.storyChapters[storyId] == nil)
    }
    
    @Test
    func onDeletedStory_whenCurrentChapterBelongsToDeletedStory_setsNewCurrentChapter() {
        let deletedStoryId = UUID()
        let remainingStoryId = UUID()
        let deletedChapter = Chapter.arrange(storyId: deletedStoryId)
        let remainingChapter = Chapter.arrange(storyId: remainingStoryId)
        let initialState = StoryState.arrange(
            currentChapter: deletedChapter,
            storyChapters: [
                deletedStoryId: [deletedChapter],
                remainingStoryId: [remainingChapter]
            ]
        )
        
        let newState = storyReducer(
            initialState,
            .onDeletedStory(deletedStoryId)
        )
        
        #expect(newState.currentChapter?.id == remainingChapter.id)
    }
    
    @Test
    func onDeletedStory_whenCurrentChapterBelongsToDeletedStoryAndNoOtherStories_setsCurrentChapterToNil() {
        let storyId = UUID()
        let chapter = Chapter.arrange(storyId: storyId)
        let initialState = StoryState.arrange(
            currentChapter: chapter,
            storyChapters: [storyId: [chapter]]
        )
        
        let newState = storyReducer(
            initialState,
            .onDeletedStory(storyId)
        )
        
        #expect(newState.currentChapter == nil)
    }
    
    @Test
    func onDeletedStory_whenCurrentChapterDoesNotBelongToDeletedStory_keepsCurrentChapter() {
        let deletedStoryId = UUID()
        let currentStoryId = UUID()
        let currentChapter = Chapter.arrange(storyId: currentStoryId)
        let deletedChapter = Chapter.arrange(storyId: deletedStoryId)
        let initialState = StoryState.arrange(
            currentChapter: currentChapter,
            storyChapters: [
                deletedStoryId: [deletedChapter],
                currentStoryId: [currentChapter]
            ]
        )
        
        let newState = storyReducer(
            initialState,
            .onDeletedStory(deletedStoryId)
        )
        
        #expect(newState.currentChapter == currentChapter)
    }
    
    @Test
    func onSavedChapter_updatesExistingChapter() {
        let storyId = UUID()
        let originalChapter = Chapter.arrange(storyId: storyId, title: "Original")
        let updatedChapter = Chapter.arrange(id: originalChapter.id, storyId: storyId, title: "Updated")
        let initialState = StoryState.arrange(
            storyChapters: [storyId: [originalChapter]]
        )
        
        let newState = storyReducer(
            initialState,
            .onSavedChapter(updatedChapter)
        )
        
        #expect(newState.storyChapters[storyId]?[0].title == "Updated")
        #expect(newState.storyChapters[storyId]?[0].id == originalChapter.id)
    }
    
    @Test
    func onSavedChapter_whenChapterNotFound_doesNotChangeState() {
        let storyId = UUID()
        let existingChapter = Chapter.arrange(storyId: storyId)
        let differentChapter = Chapter.arrange(storyId: storyId)
        let initialState = StoryState.arrange(
            storyChapters: [storyId: [existingChapter]]
        )
        
        let newState = storyReducer(
            initialState,
            .onSavedChapter(differentChapter)
        )
        
        #expect(newState.storyChapters[storyId]?[0] == existingChapter)
    }
    
    @Test
    func goToNextChapter_movesToNextChapter() {
        let storyId = UUID()
        let currentChapter = Chapter.arrange(storyId: storyId, title: "Chapter 1")
        let nextChapter = Chapter.arrange(storyId: storyId, title: "Chapter 2")
        let initialState = StoryState.arrange(
            currentChapter: currentChapter,
            storyChapters: [storyId: [currentChapter, nextChapter]]
        )
        
        let newState = storyReducer(
            initialState,
            .goToNextChapter
        )
        
        #expect(newState.currentChapter?.title == "Chapter 2")
    }
    
    @Test
    func goToNextChapter_whenOnLastChapter_doesNotChangeCurrentChapter() {
        let storyId = UUID()
        let lastChapter = Chapter.arrange(storyId: storyId)
        let initialState = StoryState.arrange(
            currentChapter: lastChapter,
            storyChapters: [storyId: [lastChapter]]
        )
        
        let newState = storyReducer(
            initialState,
            .goToNextChapter
        )
        
        #expect(newState.currentChapter == lastChapter)
    }
    
    @Test
    func goToNextChapter_whenNoCurrentChapter_doesNotChangeState() {
        let initialState = StoryState.arrange(currentChapter: nil)
        
        let newState = storyReducer(
            initialState,
            .goToNextChapter
        )
        
        #expect(newState.currentChapter == nil)
    }
    
    @Test
    func selectChapter_setsCurrentChapter() {
        let selectedChapter = Chapter.arrange
        let initialState = StoryState.arrange(currentChapter: nil)
        
        let newState = storyReducer(
            initialState,
            .selectChapter(selectedChapter)
        )
        
        #expect(newState.currentChapter == selectedChapter)
    }
    
    @Test
    func createChapter_setsIsWritingChapterTrue() {
        let initialState = StoryState.arrange(isWritingChapter: false)
        
        let newState = storyReducer(
            initialState,
            .createChapter(.newStory)
        )
        
        #expect(newState.isWritingChapter == true)
    }
    
    @Test
    func generateText_setsIsWritingChapterTrue() {
        let initialState = StoryState.arrange(isWritingChapter: false)
        
        let newState = storyReducer(
            initialState,
            .generateText(.newStory)
        )
        
        #expect(newState.isWritingChapter == true)
    }
    
    @Test
    func failedToCreateChapter_setsIsWritingChapterFalse() {
        let initialState = StoryState.arrange(isWritingChapter: true)
        
        let newState = storyReducer(
            initialState,
            .failedToCreateChapter
        )
        
        #expect(newState.isWritingChapter == false)
    }
    
    @Test
    func refreshAppSettings_updatesSettings() {
        let initialSettings = SettingsState.arrange(language: .spanish)
        let newSettings = SettingsState.arrange(language: .mandarinChinese)
        let initialState = StoryState.arrange(settings: initialSettings)
        
        let newState = storyReducer(
            initialState,
            .refreshAppSettings(newSettings)
        )
        
        #expect(newState.settings == newSettings)
    }
    
    @Test
    func updateLanguage_whenLanguageIsDifferent_updatesLanguageAndVoice() {
        let initialState = StoryState.arrange(
            settings: .arrange(voice: .elvira, language: .spanish)
        )
        
        let newState = storyReducer(
            initialState,
            .updateLanguage(.mandarinChinese)
        )
        
        #expect(newState.settings.language == .mandarinChinese)
        #expect(newState.settings.voice == .xiaoxiao)
    }
    
    @Test
    func updateLanguage_whenLanguageIsSame_doesNotChangeState() {
        let initialState = StoryState.arrange(
            settings: .arrange(voice: .elvira, language: .spanish)
        )
        
        let newState = storyReducer(
            initialState,
            .updateLanguage(.spanish)
        )
        
        #expect(newState == initialState)
        #expect(newState.settings.voice == .elvira)
    }
    
    @Test
    func onGeneratedText_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .onGeneratedText(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func generateImage_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .generateImage(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func onGeneratedImage_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .onGeneratedImage(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func generateSpeech_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .generateSpeech(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func onGeneratedSpeech_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .onGeneratedSpeech(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func generateDefinitions_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .generateDefinitions(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func onGeneratedDefinitions_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .onGeneratedDefinitions(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func loadStories_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .loadStories
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func failedToLoadStoriesAndDefinitions_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .failedToLoadStoriesAndDefinitions
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func deleteStory_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .deleteStory(UUID())
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func failedToDeleteStory_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .failedToDeleteStory
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func saveChapter_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .saveChapter(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func failedToSaveChapter_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .failedToSaveChapter
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func playSound_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .playSound(.actionButtonPress)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func beginGetNextChapter_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .beginGetNextChapter
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func saveAppSettings_doesNotChangeState() {
        let initialState = StoryState.arrange
        
        let newState = storyReducer(
            initialState,
            .saveAppSettings(.arrange)
        )
        
        #expect(newState == initialState)
    }
}
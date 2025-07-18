# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# PhraseFlow Chinese Development Guide

## Build & Test Commands
- Build: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTale" -configuration Debug build`
- Run: Open in Xcode and use ⌘R or Product > Run
- Test: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTaleTests" test`
- Run single test: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTaleTests" -only-testing:FlowTaleTests/FlowTaleStateTests/testDeviceLanguage_english test`

## Architecture Overview

### Modular Package Structure
The app is built with 18+ Swift Packages for modularity:
- **Core**: `FlowTale/` (main app), `ReduxKit`, `DataStorage/`, `Localization/`
- **Features**: `Story/`, `Audio/`, `Definition/`, `Settings/`, `Study/`, `Translation/`, `Subscription/`
- **UI**: `FTColor/`, `FTFont/`, `Media/`, `SnackBar/`, `Loading/`, `AppleIcon/`
- **Services**: `TextGeneration/`, `ImageGeneration/`, `Moderation/`, `UserLimit/`

### Redux Architecture
Strict Redux pattern with architectural constraints:
- **State composition**: `FlowTaleState` combines all feature states
- **Action hierarchy**: `FlowTaleAction` wraps feature-specific actions
- **Middleware limitations**: Can only return single action per case, no store.dispatch(...)
- **Pure reducers**: All state changes happen only in reducers
- **Async handling**: Side effects handled exclusively in middleware

### Audio System
Multi-layered audio architecture:
- **Speech Audio** (`AudioState`): Story narration with word-level timing
- **Background Music** (`MusicAudioState`): Ambient music with ducking
- **Sound Effects** (`AppAudioState`): UI interaction sounds
- **Study Audio** (`StudyState`): Separate players for word/sentence pronunciation

### Data Persistence
File-based storage system:
- **JSON encoding**: All data serialized as JSON to documents directory
- **Modular stores**: Each feature has its own data store protocol
- **Cleanup mechanisms**: Automatic orphaned file removal
- **Key stores**: `StoryDataStore`, `DefinitionDataStore`, `SettingsDataStore`

### Localization System
Comprehensive multi-language support:
- **12 languages**: English, French, Chinese, Spanish, Arabic, Hindi, Russian, Korean, Japanese, Brazilian Portuguese, European Portuguese, German
- **Type-safe strings**: All UI text through `LocalizedString` enum
- **SwiftGen integration**: Automatic string constant generation

## Default Stories System
- **Automatic loading**: New users get default stories on first launch
- **On-demand loading**: `store.dispatch(.loadDefaultStory(language: .mandarinChinese))`
- **Creation**: Use `store.dispatch(.saveAsDefaultStory(currentStory))` in DEBUG mode
- **File format**: `default_story_[language]_[uuid].json` in app bundle

## Code Style Guidelines
- **Architecture**: Follow Redux pattern with SwiftUI
- **Naming**: camelCase for variables/functions, PascalCase for types/protocols
- **Imports**: Foundation/Swift first, then UI frameworks, then others
- **Error Handling**: Use optionals with guard let unwrapping pattern
- **State Management**: Dispatch actions to store; don't modify state directly
- **View Structure**: Break down complex views into smaller components
- **Middleware**: Handle async operations, return actions based on results
- **Language Support**: All user-facing strings must use LocalizedString constants
- **Swift Concurrency**: Use async/await pattern for asynchronous operations

## Redux Constraints
- `store.dispatch(...)` cannot be run in Middleware or reducer files
- Any changes to the state can only happen in the reducer
- Middleware can only return a single action for each case
- No `store.dispatch(...)` in middleware to prevent action loops
- Don't write code with comments - keep code clean and concise
- Reuse code where possible, don't always opt to write new code if not needed

## Localization Requirements
- All user-facing text must be localized in all 12 supported languages
- Add entries to `Strings.swift` for each localized string
- Use `LocalizedString` enum for type-safe string access 

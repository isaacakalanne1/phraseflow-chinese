# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# PhraseFlow Chinese Refactoring Guide

- Each package should have a RootView
- The RootView is where the store is initialized with the environment, etc
- The Environment dependencies, which are passed into the Environment init, should also come in from the RootView init
- This will cause a chain where, ultimately, all environments, servies, etc will be initialised in the ContentView of FlowTale, and be passed in, so that there is one source of truth for each
- Only use subscriber to dispatch a store action
- Only use subscriber to dispatch a store action when this will result in functionality affecting a screen
- Otherwise, if you need functionality from another package, such as data, etc, use environment functions to call another package's environment
- Store dispatch is only used to update the state via reducer, and dispatch other actions via middleware
- State logic should only ever be involved if a view will be involved, otherwise use the environment for using functionality or data from other packages
- If there are references to the same state, use the state as expected (e.g, if there is a reference in the story package to a variable in StoryState, use this variable)
- If there are references to a different state in a package (e.g, story package has a reference to definitionState), don't try to get the definition state, instead use the environment function to get the necessary data
- I want the reducers and middlewares to be handled internally by each package, as they are now. I simply want each rootview to be shown as expected, and same with the stores. The only thing that happens at the app root level is all the environments being passed down, to be used by the other root views in the chain. This allows there to be a single source of truth for each of the environments. But the reducers, middlewares, and states are only handled internally by each package

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
- **State composition**: `State` Contains view state information
- **Action hierarchy**: `Action` refers to specific package actions, use when view logic is involved
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

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# PhraseFlow Chinese Development Guide

## Build & Test Commands
- Build: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTale" -configuration Debug build`
- Run: Open in Xcode and use ⌘R or Product > Run
- Test: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTaleTests" test`
- Run single test: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTaleTests" -only-testing:FlowTaleTests/FlowTaleStateTests/testDeviceLanguage_english test`

## Code Style Guidelines
- **Architecture**: Follow the Redux pattern with SwiftUI (state, actions, reducers, middleware)
- **Naming**: Use camelCase for variables/functions and PascalCase for types/protocols
- **Imports**: Foundation/Swift first, then UI frameworks, then others
- **Error Handling**: Use optionals with guard let unwrapping pattern
- **State Management**: Dispatch actions to the store; don't modify state directly
- **View Structure**: Break down complex views into smaller components
- **Middleware**: Handle async operations in middleware, return actions based on results
- **Language Support**: All user-facing strings must use LocalizedString constants
- **Swift Concurrency**: Use async/await pattern for asynchronous operations
- **Documentation**: Document complex functions with comments explaining purpose

Further notes:
- store.dispatch(...) cannot be run in the Middleware or reducer files
- Any changes to the state can only happen in the reducer
- Middleware can only return a single action for each case. Middleware cannot use store.dispatch(...)
- The languages for localization are English, French, Chinese, Spanish, Arabic, Hindi, Russian, Korean, Japanese, Brazilian Portuguese, European Portuguese, and German. Any requests to localize text should be localized in all these languages
- An entry should also be added to Strings.swift for the localized string
- Don't write code with comments. And keep the code clean and concise, and 
  reuse code where possible, don't always opt to write new code if you don't need to 

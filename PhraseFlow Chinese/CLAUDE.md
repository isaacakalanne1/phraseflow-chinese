# PhraseFlow Chinese Development Guide

## Build & Test Commands
- Build: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTale" -configuration Debug build`
- Run: Open in Xcode and use ⌘R or Product > Run
- Test: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTaleTests" test`
- Run single test: `xcodebuild -workspace "FlowTale.xcworkspace" -scheme "FlowTaleTests" -only-testing:FlowTaleTests/FlowTaleStateTests/testDeviceLanguage_english test`

## Code Style Guidelines
- **Architecture**: Swift UI + Redux pattern (ReduxKit)
- **Naming**: Use descriptive names with camelCase for variables/functions and PascalCase for types
- **Imports**: Group imports with Foundation/Swift first, then UI frameworks, then others
- **Error Handling**: Use optionals with guard let unwrapping pattern
- **Models**: Define enums for structured data types (Language, Difficulty, etc.)
- **Testing**: Use Given/When/Then comments in tests
- **Indentation**: 4 spaces
- **Access Control**: Mark properties as private when possible
- **SwiftUI Views**: Extract subviews for readability and reuse
- **State Management**: Use Redux store dispatch for state changes
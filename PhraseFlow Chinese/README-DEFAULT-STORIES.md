# PhraseFlow Default Stories

This document explains how to create and include default example stories in your app, which will be automatically loaded for new users.

## Using Default Stories

There are two ways default stories can be used in the app:

1. **Automatic loading for new users**: When a new user launches the app for the first time and has no stories, any default stories in the app bundle will be automatically loaded.

2. **On-demand loading by language**: You can load a default story for a specific language at any time by dispatching an action:

```swift
// Load a default story for a specific language
store.dispatch(.loadDefaultStory(language: .mandarinChinese))
```

This allows you to provide instant content for users who want to try a new language without waiting for story generation.

## Creating Default Stories

1. First, generate a story in the app that you'd like to use as a default story
2. Once the story has been generated and you're happy with it, open the Xcode debugger console
3. Assuming your main ViewController has the store as an environment object, run one of these in the debugger console:

```swift
// Option 1: Get the store and save current story (simplest approach)
let store = UIApplication.shared.windows.first?.rootViewController?.environmentObject(FlowTaleStore.self).wrappedValue
if let url = store?.saveCurrentStoryAsDefault() {
    print("Story saved to: \(url.path)")
}

// Option 2: Another way to access the store from ContentView
if let contentView = UIApplication.shared.windows.first?.rootViewController?.view as? ContentView,
   let url = contentView.store.saveCurrentStoryAsDefault() {
    print("Story saved to: \(url.path)")
}
```

4. This will save the story to your Documents directory and print the path in the console

## Adding Default Stories to Your App

After creating default stories:

1. Locate the story files in your device's Documents directory (printed in the console)
2. Copy these files to your Xcode project by dragging them into the Project Navigator
3. Make sure to select "Copy items if needed" and add to your app target
4. The files will be named in the format `default_story_[language]_[uuid].json`

## How Default Stories Work

- Default stories are only loaded for new users who have no existing stories
- When a user first launches the app, if they have no stories, the app will check for default stories in the app bundle
- Any default stories found will be automatically copied to the user's library and displayed
- This gives new users immediate content to interact with, without having to wait for story generation

## Technical Details

- Default stories are managed by the `DefaultStoryManager` class
- Stories are marked with `isDefaultStory = true` to identify their source
- In production, users can't create default stories (the saving functionality only works in DEBUG mode)
- The stories are stored in the app bundle and loaded during the first app launch if needed

## Recommended Default Stories

For the best user experience, we recommend including at least one default story for each language your app supports. This gives users a chance to immediately see how the app works with their chosen language.
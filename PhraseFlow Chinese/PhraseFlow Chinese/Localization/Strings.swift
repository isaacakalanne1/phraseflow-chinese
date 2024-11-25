// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation


public enum LocalizedString {
  public static let advanced = LocalizedString.tr("Localizable", "advanced")
  public static let aiStatement = LocalizedString.tr("Localizable", "ai_statement")
  public static let arabicGulf = LocalizedString.tr("Localizable", "arabicGulf")
  public static let beginner = LocalizedString.tr("Localizable", "beginner")
  public static func chapterNumber(_ p1: String) -> String {
    return LocalizedString.tr("Localizable", "chapter_number", p1)
  }
  public static let chineseMandarin = LocalizedString.tr("Localizable", "chinese_mandarin")
  public static let chooseStory = LocalizedString.tr("Localizable", "choose_story")
  public static let createStory = LocalizedString.tr("Localizable", "create_story")
  public static let definition = LocalizedString.tr("Localizable", "definition")
  public static let difficulty = LocalizedString.tr("Localizable", "difficulty")
  public static let expert = LocalizedString.tr("Localizable", "expert")
  public static let failedToWriteChapter = LocalizedString.tr("Localizable", "failed_to_write_chapter")
  public static let failedToWriteStory = LocalizedString.tr("Localizable", "failed_to_write_story")
  public static let french = LocalizedString.tr("Localizable", "french")
  public static let intermediate = LocalizedString.tr("Localizable", "intermediate")
  public static let japanese = LocalizedString.tr("Localizable", "japanese")
  public static let korean = LocalizedString.tr("Localizable", "korean")
  public static let language = LocalizedString.tr("Localizable", "language")
  public static let load = LocalizedString.tr("Localizable", "load")
  public static let loading = LocalizedString.tr("Localizable", "loading")
  public static let newStory = LocalizedString.tr("Localizable", "new_story")
  public static let nextChapter = LocalizedString.tr("Localizable", "next_chapter")
  public static let pause = LocalizedString.tr("Localizable", "pause")
  public static let play = LocalizedString.tr("Localizable", "play")
  public static let portugueseBrazil = LocalizedString.tr("Localizable", "portuguese_brazil")
  public static let portugueseEuropean = LocalizedString.tr("Localizable", "portuguese_european")
  public static let retry = LocalizedString.tr("Localizable", "retry")
  public static let russian = LocalizedString.tr("Localizable", "russian")
  public static let settings = LocalizedString.tr("Localizable", "settings")
  public static let spanish = LocalizedString.tr("Localizable", "spanish")
  public static let stories = LocalizedString.tr("Localizable", "stories")
  public static let storySettings = LocalizedString.tr("Localizable", "story_settings")
  public static let translation = LocalizedString.tr("Localizable", "translation")
  public static let writingNewChapter = LocalizedString.tr("Localizable", "writing_new_chapter")
}

extension LocalizedString {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

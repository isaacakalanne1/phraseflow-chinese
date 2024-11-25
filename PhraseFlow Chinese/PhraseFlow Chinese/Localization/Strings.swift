// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation


public enum LocalizedString {
  public static let advanced = LocalizedString.tr("Localizable", "advanced")
  public static let arabicGulf = LocalizedString.tr("Localizable", "arabicGulf")
  public static let beginner = LocalizedString.tr("Localizable", "beginner")
  public static let chineseMandarin = LocalizedString.tr("Localizable", "chinese_mandarin")
  public static let chooseStory = LocalizedString.tr("Localizable", "choose_story")
  public static let definition = LocalizedString.tr("Localizable", "definition")
  public static let difficulty = LocalizedString.tr("Localizable", "difficulty")
  public static let expect = LocalizedString.tr("Localizable", "Expect")
  public static let french = LocalizedString.tr("Localizable", "french")
  public static let intermediate = LocalizedString.tr("Localizable", "intermediate")
  public static let japanese = LocalizedString.tr("Localizable", "japanese")
  public static let korean = LocalizedString.tr("Localizable", "korean")
  public static let language = LocalizedString.tr("Localizable", "language")
  public static let newStory = LocalizedString.tr("Localizable", "new_story")
  public static let play = LocalizedString.tr("Localizable", "play")
  public static let portugueseBrazil = LocalizedString.tr("Localizable", "portuguese_brazil")
  public static let portugueseEuropean = LocalizedString.tr("Localizable", "portuguese_european")
  public static let russian = LocalizedString.tr("Localizable", "russian")
  public static let settings = LocalizedString.tr("Localizable", "settings")
  public static let spanish = LocalizedString.tr("Localizable", "spanish")
  public static let stories = LocalizedString.tr("Localizable", "stories")
  public static let translation = LocalizedString.tr("Localizable", "translation")
}

extension LocalizedString {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

//
//  LanguageTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Localization
import Testing
import UIKit
@testable import Settings

final class LanguageTests {
    
    @Test
    func language_autoDetect() throws {
        let language = Language.autoDetect
        
        #expect(language.rawValue == "autoDetect")
        #expect(language.displayName == LocalizedString.autoDetect)
        #expect(language.descriptiveEnglishName == "Auto detect")
        #expect(language.speechCode == "")
        #expect(language.identifier == "")
        #expect(language.voices.isEmpty)
        #expect(language.thumbnail == nil)
        #expect(language.flagEmoji == "")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_english() throws {
        let language = Language.english
        
        #expect(language.rawValue == "english")
        #expect(language.displayName == LocalizedString.englishUS)
        #expect(language.descriptiveEnglishName == "US English")
        #expect(language.speechCode == "en-US")
        #expect(language.identifier == "en")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.ava))
        #expect(language.voices.contains(.andrew))
        #expect(language.thumbnail == UIImage(named: "thumbnail-english"))
        #expect(language.flagEmoji == "🇺🇸")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_englishUK() throws {
        let language = Language.englishUK
        
        #expect(language.rawValue == "englishUK")
        #expect(language.displayName == LocalizedString.englishUK)
        #expect(language.descriptiveEnglishName == "UK English")
        #expect(language.speechCode == "en-GB")
        #expect(language.identifier == "en")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.sonia))
        #expect(language.voices.contains(.ryan))
        #expect(language.thumbnail == UIImage(named: "thumbnail-englishUK"))
        #expect(language.flagEmoji == "🇬🇧")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_mandarinChinese() throws {
        let language = Language.mandarinChinese
        
        #expect(language.rawValue == "mandarinChinese")
        #expect(language.displayName == LocalizedString.chineseMandarin)
        #expect(language.descriptiveEnglishName == "Chinese (Mandarin)")
        #expect(language.speechCode == "zh-CN")
        #expect(language.identifier == "zh")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.xiaoxiao))
        #expect(language.voices.contains(.yunjian))
        #expect(language.thumbnail == UIImage(named: "thumbnail-mandarinChinese"))
        #expect(language.flagEmoji == "🇨🇳")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_spanish() throws {
        let language = Language.spanish
        
        #expect(language.rawValue == "spanish")
        #expect(language.displayName == LocalizedString.spanish)
        #expect(language.descriptiveEnglishName == "Spanish")
        #expect(language.speechCode == "es-ES")
        #expect(language.identifier == "es")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.elvira))
        #expect(language.voices.contains(.alvaro))
        #expect(language.thumbnail == UIImage(named: "thumbnail-spanish"))
        #expect(language.flagEmoji == "🇪🇸")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_french() throws {
        let language = Language.french
        
        #expect(language.rawValue == "french")
        #expect(language.displayName == LocalizedString.french)
        #expect(language.descriptiveEnglishName == "French")
        #expect(language.speechCode == "fr-FR")
        #expect(language.identifier == "fr")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.denise))
        #expect(language.voices.contains(.henri))
        #expect(language.thumbnail == UIImage(named: "thumbnail-french"))
        #expect(language.flagEmoji == "🇫🇷")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_arabicGulf() throws {
        let language = Language.arabicGulf
        
        #expect(language.rawValue == "arabicGulf")
        #expect(language.displayName == LocalizedString.arabicGulf)
        #expect(language.descriptiveEnglishName == "Arabic (Gulf Arabic)")
        #expect(language.speechCode == "ar-AE")
        #expect(language.identifier == "ar")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.fatima))
        #expect(language.voices.contains(.hamdan))
        #expect(language.thumbnail == UIImage(named: "thumbnail-arabicGulf"))
        #expect(language.flagEmoji == "🇦🇪")
        #expect(language.alignment == .trailing)
    }
    
    @Test
    func language_japanese() throws {
        let language = Language.japanese
        
        #expect(language.rawValue == "japanese")
        #expect(language.displayName == LocalizedString.japanese)
        #expect(language.descriptiveEnglishName == "Japanese")
        #expect(language.speechCode == "ja-JP")
        #expect(language.identifier == "ja")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.mayu))
        #expect(language.voices.contains(.keita))
        #expect(language.thumbnail == UIImage(named: "thumbnail-japanese"))
        #expect(language.flagEmoji == "🇯🇵")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_korean() throws {
        let language = Language.korean
        
        #expect(language.rawValue == "korean")
        #expect(language.displayName == LocalizedString.korean)
        #expect(language.descriptiveEnglishName == "Korean")
        #expect(language.speechCode == "ko-KR")
        #expect(language.identifier == "ko")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.sunhi))
        #expect(language.voices.contains(.hyunsu))
        #expect(language.thumbnail == UIImage(named: "thumbnail-korean"))
        #expect(language.flagEmoji == "🇰🇷")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_brazilianPortuguese() throws {
        let language = Language.brazilianPortuguese
        
        #expect(language.rawValue == "brazilianPortuguese")
        #expect(language.displayName == LocalizedString.portugueseBrazil)
        #expect(language.descriptiveEnglishName == "Brazilian Portuguese")
        #expect(language.speechCode == "pt-BR")
        #expect(language.identifier == "pt")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.thalita))
        #expect(language.voices.contains(.donato))
        #expect(language.thumbnail == UIImage(named: "thumbnail-brazilianPortuguese"))
        #expect(language.flagEmoji == "🇧🇷")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_europeanPortuguese() throws {
        let language = Language.europeanPortuguese
        
        #expect(language.rawValue == "europeanPortuguese")
        #expect(language.displayName == LocalizedString.portugueseEuropean)
        #expect(language.descriptiveEnglishName == "European Portuguese")
        #expect(language.speechCode == "pt-PT")
        #expect(language.identifier == "pt")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.raquel))
        #expect(language.voices.contains(.duarte))
        #expect(language.thumbnail == UIImage(named: "thumbnail-europeanPortuguese"))
        #expect(language.flagEmoji == "🇵🇹")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_hindi() throws {
        let language = Language.hindi
        
        #expect(language.rawValue == "hindi")
        #expect(language.displayName == LocalizedString.hindi)
        #expect(language.descriptiveEnglishName == "Hindi")
        #expect(language.speechCode == "hi-IN")
        #expect(language.identifier == "hi")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.ananya))
        #expect(language.voices.contains(.aarav))
        #expect(language.thumbnail == UIImage(named: "thumbnail-hindi"))
        #expect(language.flagEmoji == "🇮🇳")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_russian() throws {
        let language = Language.russian
        
        #expect(language.rawValue == "russian")
        #expect(language.displayName == LocalizedString.russian)
        #expect(language.descriptiveEnglishName == "Russian")
        #expect(language.speechCode == "ru-RU")
        #expect(language.identifier == "ru")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.dariya))
        #expect(language.voices.contains(.dmitry))
        #expect(language.thumbnail == UIImage(named: "thumbnail-russian"))
        #expect(language.flagEmoji == "🇷🇺")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_german() throws {
        let language = Language.german
        
        #expect(language.rawValue == "german")
        #expect(language.displayName == LocalizedString.german)
        #expect(language.descriptiveEnglishName == "German")
        #expect(language.speechCode == "de-DE")
        #expect(language.identifier == "de")
        #expect(language.voices.count == 2)
        #expect(language.voices.contains(.amala))
        #expect(language.voices.contains(.conrad))
        #expect(language.thumbnail == UIImage(named: "thumbnail-german"))
        #expect(language.flagEmoji == "🇩🇪")
        #expect(language.alignment == .leading)
    }
    
    @Test
    func language_deviceLanguage() throws {
        let deviceLanguage = Language.deviceLanguage
        #expect(Language.allCases.contains(deviceLanguage))
    }
    
    @Test
    func language_schemaKey() throws {
        #expect(Language.english.schemaKey == "englishOnly")
        #expect(Language.englishUK.schemaKey == "englishUKOnly")
        #expect(Language.mandarinChinese.schemaKey == "mandarinChineseOnly")
    }
    
    @Test
    func language_key() throws {
        #expect(Language.autoDetect.key == "AutoDetect")
        #expect(Language.english.key == "English")
        #expect(Language.mandarinChinese.key == "MandarinChinese")
        #expect(Language.brazilianPortuguese.key == "BrazilianPortuguese")
        #expect(Language.europeanPortuguese.key == "EuropeanPortuguese")
    }
    
    @Test
    func language_flagCodes() throws {
        #expect(Language.autoDetect.flagCodes == [""])
        #expect(Language.english.flagCodes == ["us"])
        #expect(Language.englishUK.flagCodes == ["gb"])
        #expect(Language.mandarinChinese.flagCodes == ["cn"])
        #expect(Language.spanish.flagCodes == ["es"])
        #expect(Language.french.flagCodes == ["fr"])
        #expect(Language.arabicGulf.flagCodes == ["ae"])
        #expect(Language.japanese.flagCodes == ["jp"])
        #expect(Language.korean.flagCodes == ["kr"])
        #expect(Language.brazilianPortuguese.flagCodes == ["br"])
        #expect(Language.europeanPortuguese.flagCodes == ["pt"])
        #expect(Language.hindi.flagCodes == ["in"])
        #expect(Language.russian.flagCodes == ["ru"])
        #expect(Language.german.flagCodes == ["de"])
    }
    
    @Test
    func language_allCases() throws {
        let allCases = Language.allCases
        #expect(allCases.count == 14)
        #expect(allCases.contains(.autoDetect))
        #expect(allCases.contains(.english))
        #expect(allCases.contains(.englishUK))
        #expect(allCases.contains(.mandarinChinese))
        #expect(allCases.contains(.spanish))
        #expect(allCases.contains(.french))
        #expect(allCases.contains(.arabicGulf))
        #expect(allCases.contains(.japanese))
        #expect(allCases.contains(.korean))
        #expect(allCases.contains(.brazilianPortuguese))
        #expect(allCases.contains(.europeanPortuguese))
        #expect(allCases.contains(.hindi))
        #expect(allCases.contains(.russian))
        #expect(allCases.contains(.german))
    }
    
    @Test
    func language_codable() throws {
        for language in Language.allCases {
            let encoded = try JSONEncoder().encode(language)
            let decoded = try JSONDecoder().decode(Language.self, from: encoded)
            #expect(decoded == language)
        }
    }
}

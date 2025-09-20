//
//  VoiceTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Localization
import Testing
import UIKit
@testable import Settings

final class VoiceTests {
    
    @Test
    func voice_xiaoxiao() throws {
        let voice = Voice.xiaoxiao
        
        #expect(voice.rawValue == "xiaoxiao")
        #expect(voice.title == LocalizedString.voiceXiaoxiao)
        #expect(voice.speechSynthesisVoiceName == "zh-CN-XiaoxiaoNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-xiaoxiao"))
        #expect(voice.language == .mandarinChinese)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_yunjian() throws {
        let voice = Voice.yunjian
        
        #expect(voice.rawValue == "yunjian")
        #expect(voice.title == LocalizedString.voiceYunjian)
        #expect(voice.speechSynthesisVoiceName == "zh-CN-YunjianNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-yunjian"))
        #expect(voice.language == .mandarinChinese)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_denise() throws {
        let voice = Voice.denise
        
        #expect(voice.rawValue == "denise")
        #expect(voice.title == LocalizedString.voiceDenise)
        #expect(voice.speechSynthesisVoiceName == "fr-FR-DeniseNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-denise"))
        #expect(voice.language == .french)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_henri() throws {
        let voice = Voice.henri
        
        #expect(voice.rawValue == "henri")
        #expect(voice.title == LocalizedString.voiceHenri)
        #expect(voice.speechSynthesisVoiceName == "fr-FR-HenriNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-henri"))
        #expect(voice.language == .french)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_mayu() throws {
        let voice = Voice.mayu
        
        #expect(voice.rawValue == "mayu")
        #expect(voice.title == LocalizedString.voiceMayu)
        #expect(voice.speechSynthesisVoiceName == "ja-JP-MayuNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-mayu"))
        #expect(voice.language == .japanese)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_keita() throws {
        let voice = Voice.keita
        
        #expect(voice.rawValue == "keita")
        #expect(voice.title == LocalizedString.voiceKeita)
        #expect(voice.speechSynthesisVoiceName == "ja-JP-KeitaNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-keita"))
        #expect(voice.language == .japanese)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_sunhi() throws {
        let voice = Voice.sunhi
        
        #expect(voice.rawValue == "sunhi")
        #expect(voice.title == LocalizedString.voiceSunHi)
        #expect(voice.speechSynthesisVoiceName == "ko-KR-SunHiNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-sunhi"))
        #expect(voice.language == .korean)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_hyunsu() throws {
        let voice = Voice.hyunsu
        
        #expect(voice.rawValue == "hyunsu")
        #expect(voice.title == LocalizedString.voiceHyunSu)
        #expect(voice.speechSynthesisVoiceName == "ko-KR-HyunsuNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-hyunsu"))
        #expect(voice.language == .korean)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_dariya() throws {
        let voice = Voice.dariya
        
        #expect(voice.rawValue == "dariya")
        #expect(voice.title == LocalizedString.voiceDariya)
        #expect(voice.speechSynthesisVoiceName == "ru-RU-DariyaNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-dariya"))
        #expect(voice.language == .russian)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_dmitry() throws {
        let voice = Voice.dmitry
        
        #expect(voice.rawValue == "dmitry")
        #expect(voice.title == LocalizedString.voiceDmitry)
        #expect(voice.speechSynthesisVoiceName == "ru-RU-DmitryNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-dmitry"))
        #expect(voice.language == .russian)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_elvira() throws {
        let voice = Voice.elvira
        
        #expect(voice.rawValue == "elvira")
        #expect(voice.title == LocalizedString.voiceElvira)
        #expect(voice.speechSynthesisVoiceName == "es-ES-ElviraNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-elvira"))
        #expect(voice.language == .spanish)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_alvaro() throws {
        let voice = Voice.alvaro
        
        #expect(voice.rawValue == "alvaro")
        #expect(voice.title == LocalizedString.voiceAlvaro)
        #expect(voice.speechSynthesisVoiceName == "es-ES-AlvaroNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-alvaro"))
        #expect(voice.language == .spanish)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_fatima() throws {
        let voice = Voice.fatima
        
        #expect(voice.rawValue == "fatima")
        #expect(voice.title == LocalizedString.voiceFatima)
        #expect(voice.speechSynthesisVoiceName == "ar-AE-FatimaNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-fatima"))
        #expect(voice.language == .arabicGulf)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_hamdan() throws {
        let voice = Voice.hamdan
        
        #expect(voice.rawValue == "hamdan")
        #expect(voice.title == LocalizedString.voiceHamdan)
        #expect(voice.speechSynthesisVoiceName == "ar-AE-HamdanNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-hamdan"))
        #expect(voice.language == .arabicGulf)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_raquel() throws {
        let voice = Voice.raquel
        
        #expect(voice.rawValue == "raquel")
        #expect(voice.title == LocalizedString.voiceRaquel)
        #expect(voice.speechSynthesisVoiceName == "pt-PT-RaquelNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-raquel"))
        #expect(voice.language == .europeanPortuguese)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_duarte() throws {
        let voice = Voice.duarte
        
        #expect(voice.rawValue == "duarte")
        #expect(voice.title == LocalizedString.voiceDuarte)
        #expect(voice.speechSynthesisVoiceName == "pt-PT-DuarteNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-duarte"))
        #expect(voice.language == .europeanPortuguese)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_thalita() throws {
        let voice = Voice.thalita
        
        #expect(voice.rawValue == "thalita")
        #expect(voice.title == LocalizedString.voiceThalita)
        #expect(voice.speechSynthesisVoiceName == "pt-BR-ThalitaNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-thalita"))
        #expect(voice.language == .brazilianPortuguese)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_donato() throws {
        let voice = Voice.donato
        
        #expect(voice.rawValue == "donato")
        #expect(voice.title == LocalizedString.voiceDonato)
        #expect(voice.speechSynthesisVoiceName == "pt-BR-DonatoNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-donato"))
        #expect(voice.language == .brazilianPortuguese)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_ava() throws {
        let voice = Voice.ava
        
        #expect(voice.rawValue == "ava")
        #expect(voice.title == LocalizedString.voiceAva)
        #expect(voice.speechSynthesisVoiceName == "en-US-AvaNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-ava"))
        #expect(voice.language == .english)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_andrew() throws {
        let voice = Voice.andrew
        
        #expect(voice.rawValue == "andrew")
        #expect(voice.title == LocalizedString.voiceAndrew)
        #expect(voice.speechSynthesisVoiceName == "en-US-AndrewNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-andrew"))
        #expect(voice.language == .english)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_sonia() throws {
        let voice = Voice.sonia
        
        #expect(voice.rawValue == "sonia")
        #expect(voice.title == LocalizedString.voiceSonia)
        #expect(voice.speechSynthesisVoiceName == "en-GB-SoniaNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-sonia"))
        #expect(voice.language == .englishUK)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_ryan() throws {
        let voice = Voice.ryan
        
        #expect(voice.rawValue == "ryan")
        #expect(voice.title == LocalizedString.voiceRyan)
        #expect(voice.speechSynthesisVoiceName == "en-GB-RyanNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-ryan"))
        #expect(voice.language == .englishUK)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_ananya() throws {
        let voice = Voice.ananya
        
        #expect(voice.rawValue == "ananya")
        #expect(voice.title == LocalizedString.voiceAnanya)
        #expect(voice.speechSynthesisVoiceName == "hi-IN-AnanyaNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-ananya"))
        #expect(voice.language == .hindi)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_aarav() throws {
        let voice = Voice.aarav
        
        #expect(voice.rawValue == "aarav")
        #expect(voice.title == LocalizedString.voiceAarav)
        #expect(voice.speechSynthesisVoiceName == "hi-IN-AaravNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-aarav"))
        #expect(voice.language == .hindi)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_amala() throws {
        let voice = Voice.amala
        
        #expect(voice.rawValue == "amala")
        #expect(voice.title == LocalizedString.voiceAmala)
        #expect(voice.speechSynthesisVoiceName == "de-DE-AmalaNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-amala"))
        #expect(voice.language == .german)
        #expect(voice.gender == .female)
    }
    
    @Test
    func voice_conrad() throws {
        let voice = Voice.conrad
        
        #expect(voice.rawValue == "conrad")
        #expect(voice.title == LocalizedString.voiceConrad)
        #expect(voice.speechSynthesisVoiceName == "de-DE-ConradNeural")
        #expect(voice.thumbnail == UIImage(named: "thumbnail-conrad"))
        #expect(voice.language == .german)
        #expect(voice.gender == .male)
    }
    
    @Test
    func voice_allCases() throws {
        #expect(Voice.allCases.count == 26)
        
        let femaleVoices = Voice.allCases.filter { $0.gender == .female }
        let maleVoices = Voice.allCases.filter { $0.gender == .male }
        
        #expect(femaleVoices.count == 13)
        #expect(maleVoices.count == 13)
    }
    
    @Test
    func voice_languageGrouping() throws {
        let chineseVoices = Voice.allCases.filter { $0.language == .mandarinChinese }
        #expect(chineseVoices == [.xiaoxiao, .yunjian])
        
        let frenchVoices = Voice.allCases.filter { $0.language == .french }
        #expect(frenchVoices == [.denise, .henri])
        
        let englishUSVoices = Voice.allCases.filter { $0.language == .english }
        #expect(englishUSVoices == [.ava, .andrew])
    }
    
    @Test
    func voice_equatable() throws {
        #expect(Voice.ava == Voice.ava)
        #expect(Voice.ava != Voice.andrew)
        #expect(Voice.xiaoxiao != Voice.yunjian)
    }
    
    @Test
    func voice_codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let voice = Voice.xiaoxiao
        let data = try encoder.encode(voice)
        let decodedVoice = try decoder.decode(Voice.self, from: data)
        
        #expect(voice == decodedVoice)
    }
}
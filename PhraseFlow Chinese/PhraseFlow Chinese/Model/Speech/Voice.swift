//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaoxiao, // Chinese
         yunjian,
         denise, // French
         henri,
         mayu, // Japanese
         keita,
         sunHi, // Korean
         hyunsu,
         dariya, // Russian
         dmitry,
         elvira, // Spanish
         alvaro,
         fatima, // Arabic
         hamdan,
         raquel, // Portuguese (Portugal)
         duarte,
         thalita, // Portuguese (Brazil)
         donato,
         ava, // English (US)
         ananya, // Hindi
         aarav,
         amala, // German
         conrad

    var title: String {
        switch self {
        case .xiaoxiao:
            LocalizedString.voiceXiaoxiao
        case .yunjian:
            LocalizedString.voiceYunjian
        case .denise:
            LocalizedString.voiceDenise
        case .henri:
            LocalizedString.voiceHenri
        case .mayu:
            LocalizedString.voiceMayu
        case .keita:
            LocalizedString.voiceKeita
        case .sunHi:
            LocalizedString.voiceSunHi
        case .hyunsu:
            LocalizedString.voiceHyunSu
        case .dariya:
            LocalizedString.voiceDariya
        case .dmitry:
            LocalizedString.voiceDmitry
        case .elvira:
            LocalizedString.voiceElvira
        case .alvaro:
            LocalizedString.voiceAlvaro
        case .fatima:
            LocalizedString.voiceFatima
        case .hamdan:
            LocalizedString.voiceHamdan
        case .raquel:
            LocalizedString.voiceRaquel
        case .duarte:
            LocalizedString.voiceDuarte
        case .thalita:
            LocalizedString.voiceThalita
        case .donato:
            LocalizedString.voiceDonato
        case .ava:
            LocalizedString.voiceAva
        case .ananya:
            LocalizedString.voiceAnanya
        case .aarav:
            LocalizedString.voiceAarav
        }
    }

    var speechSynthesisVoiceName: String {
        switch self {
        case .xiaoxiao:
            "zh-CN-XiaoxiaoNeural"
        case .yunjian:
            "zh-CN-YunjianNeural"
        case .denise:
            "fr-FR-DeniseNeural"
        case .henri:
            "fr-FR-HenriNeural"
        case .mayu:
            "ja-JP-MayuNeural"
        case .keita:
            "ja-JP-KeitaNeural"
        case .sunHi:
            "ko-KR-SunHiNeural"
        case .hyunsu:
            "ko-KR-HyunsuNeural"
        case .dariya:
            "ru-RU-DariyaNeural"
        case .dmitry:
            "ru-RU-DmitryNeural"
        case .elvira:
            "es-ES-ElviraNeural"
        case .alvaro:
            "es-ES-AlvaroNeural"
        case .fatima:
            "ar-AE-FatimaNeural"
        case .hamdan:
            "ar-AE-HamdanNeural"
        case .raquel:
            "pt-PT-RaquelNeural"
        case .duarte:
            "pt-PT-DuarteNeural"
        case .thalita:
            "pt-BR-ThalitaNeural"
        case .donato:
            "pt-BR-DonatoNeural"
        case .ava:
            "en-US-AvaNeural"
        case .ananya:
            "hi-IN-AnanyaNeural"
        case .aarav:
            "hi-IN-AaravNeural"
        case .amala:
            "de-DE-AmalaNeural"
        case .conrad:
            "de-DE-ConradNeural"
        }
    }

    var gender: Gender {
        switch self {
        case .xiaoxiao,
                .denise,
                .mayu,
                .sunHi,
                .dariya,
                .elvira,
                .fatima,
                .raquel,
                .thalita,
                .ava,
                .ananya,
                .amala:
                .female
        case .yunjian,
                .henri,
                .keita,
                .alvaro,
                .hyunsu,
                .dmitry,
                .hamdan,
                .duarte,
                .donato,
                .aarav,
                .conrad:
                .male
        }
    }

    func speechStyle(isSpeech: Bool) -> SpeechStyle {
        isSpeech ? .gentle : defaultSpeechStyle
    }

    private var defaultSpeechStyle: SpeechStyle {
        switch self {
        case .xiaoxiao:
                .lyrical
        default:
                .lyrical
        }
    }
}

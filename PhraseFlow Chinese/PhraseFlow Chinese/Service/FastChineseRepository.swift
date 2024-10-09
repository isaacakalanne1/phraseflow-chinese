//
//  FastChineseRepository.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import MicrosoftCognitiveServicesSpeech

enum FastChineseRepositoryError: Error {
    case failedToSegment
    case failedToCreateSPXSpeechConfiguration
}

protocol FastChineseRepositoryProtocol {
    func speakText(_ text: String) throws
}

class FastChineseRepository: FastChineseRepositoryProtocol {

    init() {

    }

    func speakText(_ text: String) throws {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: "144bc0cdea4d44e499927e84e795b27a", region: "eastus")
        } catch {
            print("error \(error) happened")
            throw FastChineseRepositoryError.failedToCreateSPXSpeechConfiguration
        }

        speechConfig?.speechSynthesisVoiceName = "zh-CN-XiaoxiaoNeural";

        do {
            let synthesizer = try SPXSpeechSynthesizer(speechConfig!)
            let result = try synthesizer.speakText(text)
            if result.reason == SPXResultReason.canceled
            {
                let cancellationDetails = try SPXSpeechSynthesisCancellationDetails(fromCanceledSynthesisResult: result)
                print("cancelled, error code: \(cancellationDetails.errorCode) detail: \(cancellationDetails.errorDetails!) ")
                print("Did you set the speech resource key and region values?");
                return
            }
        } catch {
            throw FastChineseRepositoryError.failedToCreateSPXSpeechConfiguration
        }
    }
}

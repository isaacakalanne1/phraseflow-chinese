//
//  PhraseFlow_ChineseApp.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

@main
struct PhraseFlow_ChineseApp: App {

    private var store: FastChineseStore

    init() {

        let state = FastChineseState()
        let environment = FastChineseEnvironment()

        store = FastChineseStore(
            initial: state,
            reducer: fastChineseReducer,
            environment: environment,
            middleware: fastChineseMiddleware,
            subscriber: fastChineseSubscriber
        )

        initialiseJieba()
    }

    private func initialiseJieba() {
        let dictPath = Bundle.main.resourcePath!+"/iosjieba.bundle/dict/jieba.dict.small.utf8"
        let hmmPath = Bundle.main.resourcePath!+"/iosjieba.bundle/dict/hmm_model.utf8"
        let userDictPath = Bundle.main.resourcePath!+"/iosjieba.bundle/dict/user.dict.utf8"

        JiebaWrapper().objcJiebaInit(dictPath, forPath: hmmPath, forDictPath: userDictPath);
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
//                    store.dispatch(.loadChapter(generationInfo: <#T##ChapterGenerationInfo#>, chapterIndex: <#T##Int#>))
                }
        }
    }
}

//
//  FlowTaleStateTests.swift
//  FlowTaleTests
//
//  Created by iakalann on 23/12/2024.
//

@testable import FlowTale
import XCTest

final class FlowTaleStateTests: XCTestCase {
    var state: FlowTaleState!

    func testDeviceLanguage_english() {
        // Given
        let language = Language.english

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .english)
    }

    func testDeviceLanguage_french() {
        // Given
        let language = Language.french

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .french)
    }

    func testDeviceLanguage_arabicGulf() {
        // Given
        let language = Language.arabicGulf

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .arabicGulf)
    }

    func testDeviceLanguage_brazilianPortuguese() {
        // Given
        let language = Language.brazilianPortuguese

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .brazilianPortuguese)
    }

    func testDeviceLanguage_europeanPortuguese() {
        // Given
        let language = Language.europeanPortuguese

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .europeanPortuguese)
    }

    func testDeviceLanguage_hindi() {
        // Given
        let language = Language.hindi

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .hindi)
    }

    func testDeviceLanguage_japanese() {
        // Given
        let language = Language.japanese

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .japanese)
    }

    func testDeviceLanguage_korean() {
        // Given
        let language = Language.korean

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .korean)
    }

    func testDeviceLanguage_mandarinChinese() {
        // Given
        let language = Language.mandarinChinese

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .mandarinChinese)
    }

    func testDeviceLanguage_russian() {
        // Given
        let language = Language.russian

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .russian)
    }

    func testDeviceLanguage_spanish() {
        // Given
        let language = Language.spanish

        // When
        let state = FlowTaleState(locale: language.locale)

        // Then
        guard let deviceLanguage = state.deviceLanguage else {
            XCTFail("Should have found a device language")
            return
        }
        XCTAssertEqual(deviceLanguage, .spanish)
    }
}

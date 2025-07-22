import XCTest
@testable import Settings

final class SettingsTests: XCTestCase {
    
    func testSettingsStoreInitialization() throws {
        let store = SettingsStore()
        
        XCTAssertNotNil(store.state)
        XCTAssertEqual(store.state.difficulty, .beginner)
        XCTAssertEqual(store.state.language, .mandarinChinese)
        XCTAssertEqual(store.state.voice, .xiaoxiao)
        XCTAssertEqual(store.state.speechSpeed, .normal)
        XCTAssertTrue(store.state.isShowingDefinition)
        XCTAssertTrue(store.state.isShowingEnglish)
        XCTAssertTrue(store.state.isPlayingMusic)
        XCTAssertTrue(store.state.shouldPlaySound)
    }
    
    func testSettingsStoreEnvironment() throws {
        let store = SettingsStore()
        
        XCTAssertNotNil(store.environment)
    }
}

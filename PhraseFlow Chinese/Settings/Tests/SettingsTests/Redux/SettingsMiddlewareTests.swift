import Testing
@testable import Settings
@testable import SettingsMocks

final class SettingsMiddlewareTests {
    
    let mockEnvironment: MockSettingsEnvironment
    
    init() {
        mockEnvironment = MockSettingsEnvironment()
    }
    
    @Test
    func loadAppSettings_success() async throws {
        let expectedSettings: SettingsState = .arrange(usedCharacters: 999)
        mockEnvironment.loadAppSettingsResult = .success(expectedSettings)

        let resultAction = await settingsMiddleware(
            .arrange,
            .loadAppSettings,
            mockEnvironment
        )

        #expect(resultAction == .onLoadedAppSettings(expectedSettings))
        #expect(mockEnvironment.loadAppSettingsCalled == true)
    }
    
    @Test
    func loadAppSettings_error() async throws {
        mockEnvironment.loadAppSettingsResult = .failure(.genericError)

        let resultAction = await settingsMiddleware(
            .arrange,
            .loadAppSettings,
            mockEnvironment
        )

        #expect(resultAction == .failedToLoadAppSettings)
        #expect(mockEnvironment.loadAppSettingsCalled == true)
    }
}

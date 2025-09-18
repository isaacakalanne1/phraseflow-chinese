import Testing
@testable import Settings
@testable import SettingsMocks

final class SettingsMiddlewareTests {
    
    let mockEnvironment: MockSettingsEnvironment
    
    init() {
        mockEnvironment = MockSettingsEnvironment()
    }
    
    @Test
    func loadAppSettings() async throws {
        let action: SettingsAction = .loadAppSettings
        let settings: SettingsState = .arrange(usedCharacters: 999)

        mockEnvironment.loadAppSettingsResult = .success(settings)
        let resultAction = await settingsMiddleware(
            .arrange,
            action,
            mockEnvironment
        )

        #expect(resultAction == .onLoadedAppSettings(settings))
        #expect(mockEnvironment.loadAppSettingsCalled == true)
    }
}

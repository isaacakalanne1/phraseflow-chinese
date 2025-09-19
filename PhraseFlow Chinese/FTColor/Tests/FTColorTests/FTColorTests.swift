import Testing
import SwiftUI
@testable import FTColor

final class FTColorTests {

    @Test
    func accent() throws {
        let color = FTColor.accent
        let expectedName = "FTAccent"
        #expect(color.rawValue == expectedName)
        #expect(color.color == Color(expectedName, bundle: .module))
    }

    @Test
    func background() throws {
        let color = FTColor.background
        let expectedName = "FTBackground"
        #expect(color.rawValue == expectedName)
        #expect(color.color == Color(expectedName, bundle: .module))
    }

    @Test
    func error() throws {
        let color = FTColor.error
        let expectedName = "FTError"
        #expect(color.rawValue == expectedName)
        #expect(color.color == Color(expectedName, bundle: .module))
    }

    @Test
    func highlight() throws {
        let color = FTColor.highlight
        let expectedName = "FTHighlight"
        #expect(color.rawValue == expectedName)
        #expect(color.color == Color(expectedName, bundle: .module))
    }

    @Test
    func primary() throws {
        let color = FTColor.primary
        let expectedName = "FTPrimary"
        #expect(color.rawValue == expectedName)
        #expect(color.color == Color(expectedName, bundle: .module))
    }

    @Test
    func secondary() throws {
        let color = FTColor.secondary
        let expectedName = "FTSecondary"
        #expect(color.rawValue == expectedName)
        #expect(color.color == Color(expectedName, bundle: .module))
    }

    @Test
    func wordHighlight() throws {
        let color = FTColor.wordHighlight
        let expectedName = "FTWordHighlight"
        #expect(color.rawValue == expectedName)
        #expect(color.color == Color(expectedName, bundle: .module))
    }
}

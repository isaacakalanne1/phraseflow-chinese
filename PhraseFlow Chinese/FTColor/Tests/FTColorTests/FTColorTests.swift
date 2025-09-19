import Testing
@testable import FTColor

final class FTColorTests {

    @Test
    func accent() throws {
        let color = FTColor.accent.color
        #expect(color.name)
    }
}

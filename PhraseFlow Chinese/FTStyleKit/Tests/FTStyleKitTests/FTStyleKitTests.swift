import Testing
import SwiftUI
@testable import FTStyleKit

final class BackgroundImageTypeTests {
    
    @Test
    func main() throws {
        let type = BackgroundImageType.main
        let expectedName = "Background"
        #expect(type.name == expectedName)
        #expect(type.image == UIImage(named: expectedName))
    }
    
    @Test
    func createStory() throws {
        let type = BackgroundImageType.createStory
        let expectedName = "CreateStoryBackground"
        #expect(type.name == expectedName)
        #expect(type.image == UIImage(named: expectedName))
    }
}

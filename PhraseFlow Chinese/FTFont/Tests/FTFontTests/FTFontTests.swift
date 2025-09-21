import Testing
import SwiftUI
@testable import FTFont

final class FTFontTests {

    @Test
    func header() throws {
        let font = FTFont.header
        let fontSize = font.fontSize
        let fontWeight = font.fontWeight
        
        #expect(fontSize == 20)
        #expect(font.fontWeight == .medium)
        #expect(font.font == Font.system(size: fontSize, weight: fontWeight))
    }

    @Test
    func secondaryHeader() throws {
        let font = FTFont.secondaryHeader
        let fontSize = font.fontSize
        let fontWeight = font.fontWeight
        
        #expect(fontSize == 14)
        #expect(font.fontWeight == .medium)
        #expect(font.font == Font.system(size: fontSize, weight: fontWeight))
    }

    @Test
    func subHeader() throws {
        let font = FTFont.subHeader
        let fontSize = font.fontSize
        let fontWeight = font.fontWeight
        
        #expect(fontSize == 12)
        #expect(font.fontWeight == .medium)
        #expect(font.font == Font.system(size: fontSize, weight: fontWeight))
    }

    @Test
    func bodyXSmall() throws {
        let font = FTFont.bodyXSmall
        let fontSize = font.fontSize
        let fontWeight = font.fontWeight
        
        #expect(fontSize == 12)
        #expect(font.fontWeight == .light)
        #expect(font.font == Font.system(size: fontSize, weight: fontWeight))
    }

    @Test
    func bodySmall() throws {
        let font = FTFont.bodySmall
        let fontSize = font.fontSize
        let fontWeight = font.fontWeight
        
        #expect(fontSize == 16)
        #expect(font.fontWeight == .light)
        #expect(font.font == Font.system(size: fontSize, weight: fontWeight))
    }

    @Test
    func bodyMedium() throws {
        let font = FTFont.bodyMedium
        let fontSize = font.fontSize
        let fontWeight = font.fontWeight
        
        #expect(fontSize == 20)
        #expect(font.fontWeight == .light)
        #expect(font.font == Font.system(size: fontSize, weight: fontWeight))
    }

    @Test
    func bodyLarge() throws {
        let font = FTFont.bodyLarge
        let fontSize = font.fontSize
        let fontWeight = font.fontWeight
        
        #expect(fontSize == 30)
        #expect(font.fontWeight == .light)
        #expect(font.font == Font.system(size: fontSize, weight: fontWeight))
    }

    @Test
    func bodyXLarge() throws {
        let font = FTFont.bodyXLarge
        let fontSize = font.fontSize
        let fontWeight = font.fontWeight
        
        #expect(fontSize == 60)
        #expect(font.fontWeight == .light)
        #expect(font.font == Font.system(size: fontSize, weight: fontWeight))
    }
}

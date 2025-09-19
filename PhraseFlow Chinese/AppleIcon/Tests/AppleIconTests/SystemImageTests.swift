import Testing
@testable import AppleIcon

final class SystemImageTests {
    @Test
    func _repeat() throws {
        let image = SystemImage._repeat
        #expect(image.systemName == "repeat.circle.fill")
    }
    
    @Test
    func speaker() throws {
        let image = SystemImage.speaker
        #expect(image.systemName == "speaker.circle.fill")
    }
    
    @Test
    func pause() throws {
        let image = SystemImage.pause
        #expect(image.systemName == "pause.fill")
    }
    
    @Test
    func gear_notSelected() throws {
        let image = SystemImage.gear(isSelected: false)
        #expect(image.systemName == "gearshape")
    }
    
    @Test
    func gear_selected() throws {
        let image = SystemImage.gear(isSelected: true)
        #expect(image.systemName == "gearshape.2.fill")
    }
    
    @Test
    func pencil_notSelected() throws {
        let image = SystemImage.pencil(isSelected: false)
        #expect(image.systemName == "square.and.pencil")
    }
    
    @Test
    func pencil_selected() throws {
        let image = SystemImage.pencil(isSelected: true)
        #expect(image.systemName == "pencil.and.outline")
    }
    
    @Test
    func play() throws {
        let image = SystemImage.play
        #expect(image.systemName == "play.fill")
    }
    
    @Test
    func stop() throws {
        let image = SystemImage.stop
        #expect(image.systemName == "stop.circle.fill")
    }
    
    @Test
    func list_notSelected() throws {
        let image = SystemImage.list(isSelected: false)
        #expect(image.systemName == "list.bullet.rectangle.portrait")
    }
    
    @Test
    func list_selected() throws {
        let image = SystemImage.list(isSelected: true)
        #expect(image.systemName == "doc.text.magnifyingglass")
    }
    
    @Test
    func ellipsis() throws {
        let image = SystemImage.ellipsis
        #expect(image.systemName == "ellipsis.circle")
    }
    
    @Test
    func arrowDown() throws {
        let image = SystemImage.arrowDown
        #expect(image.systemName == "arrow.down.to.line.circle.fill")
    }
    
    @Test
    func heart_notSelected() throws {
        let image = SystemImage.heart(isSelected: false)
        #expect(image.systemName == "suit.heart")
    }
    
    @Test
    func heart_selected() throws {
        let image = SystemImage.heart(isSelected: true)
        #expect(image.systemName == "suit.heart.fill")
    }
    
    @Test
    func starFilled() throws {
        let image = SystemImage.starFilled
        #expect(image.systemName == "star.fill")
    }
    
    @Test
    func star() throws {
        let image = SystemImage.star
        #expect(image.systemName == "star")
    }
    
    @Test
    func book_notSelected() throws {
        let image = SystemImage.book(isSelected: false)
        #expect(image.systemName == "book.closed")
    }
    
    @Test
    func book_selected() throws {
        let image = SystemImage.book(isSelected: true)
        #expect(image.systemName == "book.fill")
    }
    
    @Test
    func chartLine_notSelected() throws {
        let image = SystemImage.chartLine(isSelected: false)
        #expect(image.systemName == "chart.xyaxis.line")
    }
    
    @Test
    func chartLine_selected() throws {
        let image = SystemImage.chartLine(isSelected: true)
        #expect(image.systemName == "chart.line.uptrend.xyaxis")
    }
    
    @Test
    func plus_notSelected() throws {
        let image = SystemImage.plus(isSelected: false)
        #expect(image.systemName == "plus.circle")
    }
    
    @Test
    func plus_selected() throws {
        let image = SystemImage.plus(isSelected: true)
        #expect(image.systemName == "plus.message.fill")
    }
    
    @Test
    func chevronRight() throws {
        let image = SystemImage.chevronRight
        #expect(image.systemName == "chevron.right.square.fill")
    }
    
    @Test
    func translate_notSelected() throws {
        let image = SystemImage.translate(isSelected: false)
        #expect(image.systemName == "character.bubble")
    }
    
    @Test
    func translate_selected() throws {
        let image = SystemImage.translate(isSelected: true)
        #expect(image.systemName == "character.bubble.fill")
    }
    
    @Test
    func xmark() throws {
        let image = SystemImage.xmark
        #expect(image.systemName == "xmark.circle.fill")
    }
}

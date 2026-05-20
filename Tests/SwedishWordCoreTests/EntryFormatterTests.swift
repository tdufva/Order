import XCTest
@testable import SwedishWordCore

final class EntryFormatterTests: XCTestCase {
  func testSentenceTrimmedKeepsCompleteSentencesWithUTF8Text() {
    let text = "Första meningen innehåller å, ä och ö. Andra meningen ska inte bli en halv mening."

    let trimmed = EntryFormatter.sentenceTrimmed(text, maxCharacters: 52)

    XCTAssertEqual(trimmed, "Första meningen innehåller å, ä och ö. ...")
  }

  func testSentenceTrimmedDropsSentenceThatCannotFit() {
    let text = "Detta är en mycket lång mening som inte får kapas mitt i texten."

    let trimmed = EntryFormatter.sentenceTrimmed(text, maxCharacters: 24)

    XCTAssertEqual(trimmed, "")
  }

  func testSentenceTrimmedNormalizesLineBreaks() {
    let text = "Första meningen.\nAndra meningen ska vänta."

    let trimmed = EntryFormatter.sentenceTrimmed(text, maxCharacters: 24)

    XCTAssertEqual(trimmed, "Första meningen. ...")
  }
}

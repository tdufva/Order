import XCTest
@testable import SwedishWordCore

final class CSVParserTests: XCTestCase {
  func testParsesUTF8CharactersAndQuotedCommas() throws {
    let csv = """
    id,svenska,ordklass,förklaring_sv,kort_förklaring_sv,suomeksi,område,källa_url
    1,"återkoppling, estetisk",substantiv,"Förklaring med å, ä, ö och komma, samt semikolon; i texten.",Kort text,palaute,"bildpedagogik, konstpedagogik",https://example.com/källa
    """

    let entries = try VocabularyStore.parseEntries(fromCSVString: csv)

    XCTAssertEqual(entries.count, 1)
    XCTAssertEqual(entries[0].svenska, "återkoppling, estetisk")
    XCTAssertEqual(entries[0].forklaringSV, "Förklaring med å, ä, ö och komma, samt semikolon; i texten.")
    XCTAssertEqual(entries[0].omrade, "bildpedagogik, konstpedagogik")
    XCTAssertEqual(entries[0].kallaURL, "https://example.com/källa")
  }

  func testParsesQuotedLineBreaksAndEscapedQuotes() throws {
    let csv = """
    svenska,ordklass,förklaring_sv,kort_förklaring_sv,suomeksi,område,källa_url
    begrepp,substantiv,"Rad ett
    rad två med ""citat"".",Kort,begreppi,teori,https://example.com
    """

    let entries = try VocabularyStore.parseEntries(fromCSVString: csv)

    XCTAssertEqual(entries[0].forklaringSV, "Rad ett\nrad två med \"citat\".")
  }

  func testParserDetectsSemicolonDelimitedCSV() throws {
    let csv = """
    svenska;ordklass;förklaring_sv;kort_förklaring_sv;suomeksi;område;källa_url
    situering;substantiv;"Text med, komma";Kort;paikantuminen;feministisk forskning;https://example.com
    """

    let entries = try VocabularyStore.parseEntries(fromCSVString: csv)

    XCTAssertEqual(entries[0].svenska, "situering")
    XCTAssertEqual(entries[0].forklaringSV, "Text med, komma")
  }

  func testEmptyCSVUsesFallbackStore() {
    let store = VocabularyStore.store(fromCSVString: "")

    XCTAssertTrue(store.isUsingFallback)
    XCTAssertEqual(store.entries.first?.svenska, VocabularyEntry.fallback.svenska)
  }

  func testBundledVocabularyLoadsRealCSV() throws {
    let store = try VocabularyStore.bundled()

    XCTAssertGreaterThan(store.entries.count, 700)
    XCTAssertEqual(store.entries.first?.svenska, "agens")
    XCTAssertEqual(store.entries.first?.suomeksi, "toimijuus")
  }
}

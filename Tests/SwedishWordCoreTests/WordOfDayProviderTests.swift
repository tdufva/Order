import Foundation
import XCTest
@testable import SwedishWordCore

final class WordOfDayProviderTests: XCTestCase {
  private let entries = [
    VocabularyEntry(id: 0, svenska: "ett", ordklass: "substantiv", forklaringSV: "A", kortForklaringSV: "A", suomeksi: "yksi", omrade: "test", kallaURL: ""),
    VocabularyEntry(id: 1, svenska: "två", ordklass: "substantiv", forklaringSV: "B", kortForklaringSV: "B", suomeksi: "kaksi", omrade: "test", kallaURL: ""),
    VocabularyEntry(id: 2, svenska: "tre", ordklass: "substantiv", forklaringSV: "C", kortForklaringSV: "C", suomeksi: "kolme", omrade: "test", kallaURL: "")
  ]

  func testEpochDateSelectsFirstEntry() throws {
    let calendar = testCalendar
    let date = try makeDate(year: 2026, month: 1, day: 1, hour: 12, calendar: calendar)

    let provider = WordOfDayProvider(entries: entries)

    XCTAssertEqual(provider.index(for: date, calendar: calendar), 0)
    XCTAssertEqual(provider.entry(for: date, calendar: calendar).svenska, "ett")
  }

  func testDifferentDatesReturnExpectedIndices() throws {
    let calendar = testCalendar
    let provider = WordOfDayProvider(entries: entries)

    XCTAssertEqual(provider.index(for: try makeDate(year: 2026, month: 1, day: 2, calendar: calendar), calendar: calendar), 1)
    XCTAssertEqual(provider.index(for: try makeDate(year: 2026, month: 1, day: 3, calendar: calendar), calendar: calendar), 2)
    XCTAssertEqual(provider.index(for: try makeDate(year: 2026, month: 1, day: 4, calendar: calendar), calendar: calendar), 0)
  }

  func testSameLocalDateReturnsSameWord() throws {
    let calendar = testCalendar
    let provider = WordOfDayProvider(entries: entries)

    let morning = try makeDate(year: 2026, month: 4, day: 14, hour: 8, calendar: calendar)
    let evening = try makeDate(year: 2026, month: 4, day: 14, hour: 22, calendar: calendar)

    XCTAssertEqual(provider.entry(for: morning, calendar: calendar), provider.entry(for: evening, calendar: calendar))
  }

  func testDateBeforeEpochStillProducesStablePositiveIndex() throws {
    let calendar = testCalendar
    let provider = WordOfDayProvider(entries: entries)
    let date = try makeDate(year: 2025, month: 12, day: 31, calendar: calendar)

    XCTAssertEqual(provider.index(for: date, calendar: calendar), 2)
  }

  func testNextRefreshIsShortlyAfterNextLocalMidnight() throws {
    let calendar = testCalendar
    let date = try makeDate(year: 2026, month: 5, day: 19, hour: 13, minute: 30, calendar: calendar)
    let refresh = WordOfDayProvider.nextRefreshDate(after: date, calendar: calendar)
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: refresh)

    XCTAssertEqual(components.year, 2026)
    XCTAssertEqual(components.month, 5)
    XCTAssertEqual(components.day, 20)
    XCTAssertEqual(components.hour, 0)
    XCTAssertEqual(components.minute, 5)
  }

  private var testCalendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Europe/Helsinki")!
    return calendar
  }

  private func makeDate(
    year: Int,
    month: Int,
    day: Int,
    hour: Int = 12,
    minute: Int = 0,
    calendar: Calendar
  ) throws -> Date {
    let date = calendar.date(from: DateComponents(
      calendar: calendar,
      timeZone: calendar.timeZone,
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute
    ))

    return try XCTUnwrap(date)
  }
}

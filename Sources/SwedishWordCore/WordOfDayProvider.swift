import Foundation

public struct WordOfDayProvider: Sendable {
  public let entries: [VocabularyEntry]

  public init(entries: [VocabularyEntry]) {
    self.entries = entries.isEmpty ? VocabularyEntry.fallbackEntries : entries
  }

  public func entry(for date: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> VocabularyEntry {
    let index = Self.index(for: date, entryCount: entries.count, calendar: calendar)
    return entries[index]
  }

  public func index(for date: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> Int {
    Self.index(for: date, entryCount: entries.count, calendar: calendar)
  }

  public static func index(for date: Date, entryCount: Int, calendar: Calendar = .autoupdatingCurrent) -> Int {
    guard entryCount > 0 else { return 0 }

    let epoch = epochStartDate(in: calendar)
    let epochStartOfDay = calendar.startOfDay(for: epoch)
    let todayStartOfDay = calendar.startOfDay(for: date)
    let dayIndex = calendar.dateComponents([.day], from: epochStartOfDay, to: todayStartOfDay).day ?? 0

    return positiveModulo(dayIndex, by: entryCount)
  }

  public static func nextRefreshDate(after date: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> Date {
    let startOfToday = calendar.startOfDay(for: date)
    let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? date.addingTimeInterval(24 * 60 * 60)
    return calendar.date(byAdding: .minute, value: 5, to: startOfTomorrow) ?? startOfTomorrow.addingTimeInterval(5 * 60)
  }

  private static func epochStartDate(in calendar: Calendar) -> Date {
    var gregorian = Calendar(identifier: .gregorian)
    gregorian.timeZone = calendar.timeZone
    return gregorian.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date(timeIntervalSince1970: 1_767_225_600)
  }

  private static func positiveModulo(_ value: Int, by divisor: Int) -> Int {
    let remainder = value % divisor
    return remainder >= 0 ? remainder : remainder + divisor
  }
}

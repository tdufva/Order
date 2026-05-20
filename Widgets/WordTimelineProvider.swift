import WidgetKit
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

struct WordTimelineEntry: TimelineEntry {
  let date: Date
  let entry: VocabularyEntry
}

struct WordTimelineProvider: TimelineProvider {
  func placeholder(in context: Context) -> WordTimelineEntry {
    WordTimelineEntry(date: Date(), entry: .fallback)
  }

  func getSnapshot(in context: Context, completion: @escaping (WordTimelineEntry) -> Void) {
    completion(timelineEntry(for: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<WordTimelineEntry>) -> Void) {
    let now = Date()
    let timelineEntry = timelineEntry(for: now)
    let refreshDate = WordOfDayProvider.nextRefreshDate(after: now)
    completion(Timeline(entries: [timelineEntry], policy: .after(refreshDate)))
  }

  private func timelineEntry(for date: Date) -> WordTimelineEntry {
    let store = VocabularyStore.bundledWithFallback()
    let entry = WordOfDayProvider(entries: store.entries).entry(for: date)
    return WordTimelineEntry(date: date, entry: entry)
  }
}

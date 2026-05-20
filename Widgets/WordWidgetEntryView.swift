import SwiftUI
import WidgetKit
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

struct WordWidgetEntryView: View {
  let timelineEntry: WordTimelineEntry
  @Environment(\.widgetFamily) private var widgetFamily

  var body: some View {
    Group {
      switch widgetFamily {
      case .accessoryInline:
        Text("\(timelineEntry.entry.svenska): \(EntryFormatter.trimmed(timelineEntry.entry.kortForklaringSV, maxCharacters: 44))")
      case .accessoryRectangular:
        AccessoryRectangularWordView(entry: timelineEntry.entry)
      case .systemSmall:
        SmallWordWidgetView(entry: timelineEntry.entry)
      case .systemMedium:
        MediumWordWidgetView(entry: timelineEntry.entry)
      case .systemLarge:
        LargeWordWidgetView(entry: timelineEntry.entry)
      default:
        SmallWordWidgetView(entry: timelineEntry.entry)
      }
    }
    .containerBackground(for: .widget) {
      WidgetBackground()
    }
  }
}

private struct AccessoryRectangularWordView: View {
  let entry: VocabularyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(entry.svenska)
        .font(.headline)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
      Text(entry.kortForklaringSV)
        .font(.caption2)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
      Text(entry.suomeksi)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
  }
}

private struct SmallWordWidgetView: View {
  let entry: VocabularyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(entry.svenska)
        .font(.headline)
        .fontDesign(.serif)
        .foregroundStyle(.white)
        .lineLimit(2)
        .minimumScaleFactor(0.75)
      Text(entry.suomeksi)
        .font(.subheadline)
        .foregroundStyle(OrderDesign.goldenYellow)
        .lineLimit(1)
      Spacer(minLength: 4)
      Text(entry.kortForklaringSV)
        .font(.caption)
        .foregroundStyle(.white.opacity(0.86))
        .minimumScaleFactor(0.85)
        .lineLimit(3)
        .truncationMode(.tail)
    }
    .padding()
  }
}

private struct MediumWordWidgetView: View {
  let entry: VocabularyEntry

  var body: some View {
    ViewThatFits(in: .vertical) {
      MediumWordWidgetContent(
        entry: entry,
        longExplanation: EntryFormatter.sentenceTrimmed(entry.forklaringSV, maxCharacters: 130),
        longExplanationLineLimit: 3
      )
      MediumWordWidgetContent(
        entry: entry,
        longExplanation: EntryFormatter.sentenceTrimmed(entry.forklaringSV, maxCharacters: 88),
        longExplanationLineLimit: 2
      )
      MediumWordWidgetContent(
        entry: entry,
        longExplanation: "",
        longExplanationLineLimit: 0
      )
    }
  }
}

private struct LargeWordWidgetView: View {
  let entry: VocabularyEntry

  var body: some View {
    ViewThatFits(in: .vertical) {
      LargeWordWidgetContent(
        entry: entry,
        longExplanation: EntryFormatter.sentenceTrimmed(entry.forklaringSV, maxCharacters: 280),
        longExplanationLineLimit: 8,
        showsSource: true
      )
      LargeWordWidgetContent(
        entry: entry,
        longExplanation: EntryFormatter.sentenceTrimmed(entry.forklaringSV, maxCharacters: 190),
        longExplanationLineLimit: 5,
        showsSource: false
      )
      LargeWordWidgetContent(
        entry: entry,
        longExplanation: "",
        longExplanationLineLimit: 0,
        showsSource: false
      )
    }
  }
}

private struct MediumWordWidgetContent: View {
  let entry: VocabularyEntry
  let longExplanation: String
  let longExplanationLineLimit: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .firstTextBaseline) {
        Text(entry.svenska)
          .font(.title3)
          .fontDesign(.serif)
          .fontWeight(.semibold)
          .foregroundStyle(.white)
          .lineLimit(1)
          .minimumScaleFactor(0.75)
        Spacer(minLength: 8)
        Text(entry.ordklass)
          .font(.caption)
          .foregroundStyle(OrderDesign.goldenYellow)
          .lineLimit(1)
      }

      Text(entry.suomeksi)
        .font(.subheadline)
        .foregroundStyle(.white.opacity(0.82))
        .lineLimit(1)

      Text(entry.kortForklaringSV)
        .font(.callout)
        .foregroundStyle(.white)
        .lineLimit(2)
        .minimumScaleFactor(0.82)

      if !longExplanation.isEmpty {
        Text(longExplanation)
          .font(.caption)
          .foregroundStyle(.white.opacity(0.78))
          .lineLimit(longExplanationLineLimit)
      }
    }
    .padding()
  }
}

private struct LargeWordWidgetContent: View {
  let entry: VocabularyEntry
  let longExplanation: String
  let longExplanationLineLimit: Int
  let showsSource: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(entry.svenska)
        .font(.title2)
        .fontDesign(.serif)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .lineLimit(2)
        .minimumScaleFactor(0.75)

      Text(entry.suomeksi)
        .font(.title3)
        .foregroundStyle(OrderDesign.goldenYellow)
        .lineLimit(1)

      ViewThatFits(in: .horizontal) {
        HStack {
          Label(entry.ordklass, systemImage: "textformat")
          Label(entry.omrade, systemImage: "folder")
        }
        VStack(alignment: .leading, spacing: 3) {
          Label(entry.ordklass, systemImage: "textformat")
          Label(entry.omrade, systemImage: "folder")
        }
      }
      .font(.caption)
      .foregroundStyle(.white.opacity(0.76))
      .lineLimit(1)

      Text(entry.kortForklaringSV)
        .font(.headline)
        .foregroundStyle(.white)
        .lineLimit(2)
        .minimumScaleFactor(0.85)

      if !longExplanation.isEmpty {
        Text(longExplanation)
          .font(.callout)
          .foregroundStyle(.white.opacity(0.80))
          .lineLimit(longExplanationLineLimit)
      }

      Spacer(minLength: 0)

      if showsSource, let domain = entry.sourceDomain {
        Text(domain)
          .font(.caption2)
          .foregroundStyle(.white.opacity(0.62))
          .lineLimit(1)
      }
    }
    .padding()
  }
}

private struct WidgetBackground: View {
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      OrderDesign.widgetBackground
      Rectangle()
        .fill(OrderDesign.goldenYellow)
        .frame(height: 5)
    }
  }
}

#Preview(as: .systemMedium) {
  OrderWidget()
} timeline: {
  WordTimelineEntry(date: Date(), entry: .fallback)
}

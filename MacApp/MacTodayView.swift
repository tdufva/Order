import SwiftUI
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

struct MacTodayView: View {
  let store: VocabularyStore

  @State private var selectedDate = Date()
  @State private var searchText = ""
  @State private var selectedEntryID: VocabularyEntry.ID?

  private var provider: WordOfDayProvider {
    WordOfDayProvider(entries: store.entries)
  }

  private var wordForSelectedDate: VocabularyEntry {
    provider.entry(for: selectedDate)
  }

  private var displayedEntry: VocabularyEntry {
    if let selectedEntryID,
       let selectedEntry = store.entries.first(where: { $0.id == selectedEntryID }) {
      return selectedEntry
    }
    return wordForSelectedDate
  }

  private var searchResults: [VocabularyEntry] {
    VocabularySearch.results(matching: searchText, in: store.entries)
  }

  var body: some View {
    NavigationSplitView {
      List(selection: $selectedEntryID) {
        Section("Dagens ord") {
          Button {
            selectedEntryID = nil
            selectedDate = Date()
          } label: {
            Label("Visa idag", systemImage: "sun.max")
          }
          .buttonStyle(.plain)
        }

        Section("Sanasto") {
          ForEach(searchResults) { entry in
            HStack(alignment: .top, spacing: 8) {
              Capsule()
                .fill(OrderDesign.goldenYellow)
                .frame(width: 3)
                .padding(.vertical, 3)

              VStack(alignment: .leading, spacing: 3) {
                Text(entry.svenska)
                  .font(.headline)
                  .foregroundStyle(OrderDesign.royalBlue)
                  .lineLimit(1)
                  .truncationMode(.tail)
                Text(entry.suomeksi)
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
                  .truncationMode(.tail)
              }
            }
            .padding(.vertical, 3)
            .tag(Optional(entry.id))
          }
        }
      }
      .listStyle(.sidebar)
      .searchable(text: $searchText, prompt: "Sök ord, område, förklaring")
      .tint(OrderDesign.royalBlue)
      .safeAreaInset(edge: .bottom) {
        if let loadErrorDescription = store.loadErrorDescription {
          Text(loadErrorDescription)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial)
        }
      }
    } detail: {
      MacEntryDetailView(
        entry: displayedEntry,
        selectedDate: selectedEntryID == nil ? selectedDate : nil,
        onCopyWord: { MacClipboard.copy(displayedEntry.svenska) },
        onCopyFinnish: { MacClipboard.copy(displayedEntry.suomeksi) },
        onCopyFullEntry: { MacClipboard.copy(EntryFormatter.fullEntry(displayedEntry)) }
      )
      .toolbar {
        ToolbarItemGroup(placement: .primaryAction) {
          Button {
            moveSelectedDate(by: -1)
          } label: {
            Label("Previous Day", systemImage: "chevron.left")
          }
          .disabled(selectedEntryID != nil)

          Button("Today") {
            selectedEntryID = nil
            selectedDate = Date()
          }

          Button {
            moveSelectedDate(by: 1)
          } label: {
            Label("Next Day", systemImage: "chevron.right")
          }
          .disabled(selectedEntryID != nil)
        }
      }
      .tint(OrderDesign.royalBlue)
    }
  }

  private func moveSelectedDate(by days: Int) {
    selectedEntryID = nil
    selectedDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate
  }
}

private struct MacEntryDetailView: View {
  let entry: VocabularyEntry
  let selectedDate: Date?
  let onCopyWord: () -> Void
  let onCopyFinnish: () -> Void
  let onCopyFullEntry: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 12) {
          if let selectedDate {
            Text(selectedDate.formatted(date: .long, time: .omitted))
              .font(.subheadline)
              .foregroundStyle(OrderDesign.goldenYellow)
              .lineLimit(1)
          }

          OrderDesign.goldRule

          Text(entry.svenska)
            .font(.system(.largeTitle, design: .serif, weight: .semibold))
            .foregroundStyle(.white)
            .textSelection(.enabled)
            .lineLimit(3)
            .minimumScaleFactor(0.58)
            .allowsTightening(true)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text(entry.suomeksi)
            .font(.title2)
            .foregroundStyle(.white.opacity(0.82))
            .textSelection(.enabled)
            .lineLimit(2)
            .minimumScaleFactor(0.75)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OrderDesign.royalBlue, in: RoundedRectangle(cornerRadius: OrderDesign.cornerRadius, style: .continuous))
        .overlay(alignment: .bottomLeading) {
          Rectangle()
            .fill(OrderDesign.goldenYellow)
            .frame(height: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: OrderDesign.cornerRadius, style: .continuous))

        ViewThatFits(in: .horizontal) {
          copyButtonRow
          copyButtonColumn
        }
        .buttonStyle(.bordered)
        .tint(OrderDesign.royalBlue)

        VStack(alignment: .leading, spacing: 10) {
          MacMetadataRow(title: "Ordklass", value: entry.ordklass)
          MacMetadataRow(title: "Område", value: entry.omrade)
        }
        .font(.callout)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .orderSurface(tint: OrderDesign.royalBlue.opacity(0.14))

        VStack(alignment: .leading, spacing: 8) {
          Text("Kort förklaring")
            .font(.headline)
            .foregroundStyle(OrderDesign.royalBlue)
            .lineLimit(1)
          Text(entry.kortForklaringSV.isEmpty ? "-" : entry.kortForklaringSV)
            .font(.title3)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .orderSurface(tint: OrderDesign.goldenYellow.opacity(0.30))

        VStack(alignment: .leading, spacing: 8) {
          Text("Förklaring")
            .font(.headline)
            .foregroundStyle(OrderDesign.royalBlue)
            .lineLimit(1)
          Text(entry.forklaringSV.isEmpty ? "-" : entry.forklaringSV)
            .font(.body)
            .lineSpacing(3)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
        }

        if let url = entry.sourceURL {
          Link(destination: url) {
            Label(entry.sourceDomain ?? "Källa", systemImage: "link")
              .lineLimit(1)
              .truncationMode(.middle)
          }
          .buttonStyle(.bordered)
          .tint(OrderDesign.royalBlue)
        }
      }
      .padding(32)
      .frame(maxWidth: 840, alignment: .leading)
      .frame(maxWidth: .infinity)
    }
    .background(OrderAppBackground())
  }

  private var copyButtonRow: some View {
    HStack(spacing: 10) {
      Button {
        onCopyWord()
      } label: {
        Label("Copy Swedish", systemImage: "doc.on.doc")
          .lineLimit(1)
      }

      Button {
        onCopyFinnish()
      } label: {
        Label("Copy Finnish", systemImage: "doc.on.doc.fill")
          .lineLimit(1)
      }

      Button {
        onCopyFullEntry()
      } label: {
        Label("Copy Entry", systemImage: "doc.text")
          .lineLimit(1)
      }
    }
  }

  private var copyButtonColumn: some View {
    VStack(alignment: .leading, spacing: 8) {
      Button {
        onCopyWord()
      } label: {
        Label("Copy Swedish", systemImage: "doc.on.doc")
          .lineLimit(1)
      }

      Button {
        onCopyFinnish()
      } label: {
        Label("Copy Finnish", systemImage: "doc.on.doc.fill")
          .lineLimit(1)
      }

      Button {
        onCopyFullEntry()
      } label: {
        Label("Copy Entry", systemImage: "doc.text")
          .lineLimit(1)
      }
    }
  }
}

private struct MacMetadataRow: View {
  let title: String
  let value: String

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 14) {
      Text(title)
        .foregroundStyle(.secondary)
        .frame(width: 72, alignment: .leading)
      Text(value.isEmpty ? "-" : value)
        .fontWeight(.medium)
        .lineLimit(4)
        .minimumScaleFactor(0.82)
        .truncationMode(.tail)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  MacTodayView(store: .init(entries: VocabularyEntry.fallbackEntries))
    .frame(width: 920, height: 640)
}

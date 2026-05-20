import AppKit
import SwiftUI
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

struct MenuBarWordView: View {
  let store: VocabularyStore
  @Environment(\.openWindow) private var openWindow

  private var entry: VocabularyEntry {
    WordOfDayProvider(entries: store.entries).entry()
  }

  var body: some View {
    Text(EntryFormatter.menuTitle(entry.svenska))
      .font(.headline)
      .foregroundStyle(OrderDesign.royalBlue)
      .lineLimit(1)
    Text(EntryFormatter.menuTitle(entry.suomeksi))
      .lineLimit(1)
    Text(EntryFormatter.menuTitle(entry.kortForklaringSV, maxCharacters: 64))
      .foregroundStyle(.secondary)
      .lineLimit(2)

    Divider()

    Button {
      openWindow(id: "main")
      NSApp.activate(ignoringOtherApps: true)
    } label: {
      Label("Open Full Entry", systemImage: "book")
    }

    Button {
      MacClipboard.copy(entry.svenska)
    } label: {
      Label("Copy Word", systemImage: "doc.on.doc")
    }

    Button {
      MacClipboard.copy(EntryFormatter.fullEntry(entry))
    } label: {
      Label("Copy Entry", systemImage: "doc.text")
    }

    Divider()

    Button {
      NSApplication.shared.terminate(nil)
    } label: {
      Label("Quit", systemImage: "power")
    }
  }
}

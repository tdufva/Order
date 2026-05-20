import AppKit
import SwiftUI
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

final class OrderAppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
  }
}

@main
struct OrderMacApp: App {
  @NSApplicationDelegateAdaptor(OrderAppDelegate.self) private var appDelegate

  private let store = VocabularyStore.bundledWithFallback()

  private var todayEntry: VocabularyEntry {
    WordOfDayProvider(entries: store.entries).entry()
  }

  var body: some Scene {
    WindowGroup("Order", id: "main") {
      MacTodayView(store: store)
        .frame(minWidth: 860, minHeight: 620)
        .tint(OrderDesign.royalBlue)
    }
    .commands {
      CommandGroup(after: .newItem) {
        Button("Copy Today's Word") {
          MacClipboard.copy(todayEntry.svenska)
        }
        .keyboardShortcut("c", modifiers: [.command, .shift])

        Button("Copy Today's Entry") {
          MacClipboard.copy(EntryFormatter.fullEntry(todayEntry))
        }
        .keyboardShortcut("c", modifiers: [.command, .option])
      }
    }

    MenuBarExtra(EntryFormatter.menuTitle(todayEntry.svenska, maxCharacters: 18), systemImage: "text.book.closed") {
      MenuBarWordView(store: store)
    }
    .menuBarExtraStyle(.menu)
  }
}

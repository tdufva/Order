import AppKit
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

enum MacClipboard {
  static func copy(_ value: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(value, forType: .string)
  }
}

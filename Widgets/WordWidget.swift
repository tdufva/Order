import SwiftUI
import WidgetKit
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

@main
struct OrderWidgetBundle: WidgetBundle {
  var body: some Widget {
    OrderWidget()
  }
}

struct OrderWidget: Widget {
  private let kind = "OrderWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: WordTimelineProvider()) { entry in
      WordWidgetEntryView(timelineEntry: entry)
    }
    .configurationDisplayName("Svenskt forskningsord")
    .description("Dagens svenska forskningsord med finsk översättning.")
    .supportedFamilies(Self.supportedFamilies)
  }

  private static var supportedFamilies: [WidgetFamily] {
    #if os(iOS)
    [.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular]
    #else
    [.systemSmall, .systemMedium, .systemLarge]
    #endif
  }
}

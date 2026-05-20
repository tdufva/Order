import SwiftUI
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

@main
struct OrderiOSApp: App {
  private let store = VocabularyStore.bundledWithFallback()

  var body: some Scene {
    WindowGroup {
      IOSRootView(store: store)
    }
  }
}

struct IOSRootView: View {
  let store: VocabularyStore
  @State private var selectedSection: IOSRootSection = .today

  var body: some View {
    ZStack {
      switch selectedSection {
      case .today:
        IOSTodayWordView(store: store)
      case .search:
        NavigationStack {
          IOSSearchView(entries: store.entries)
        }
      }
    }
    .safeAreaInset(edge: .bottom) {
      IOSCompactTabBar(selectedSection: $selectedSection)
    }
    .tint(OrderDesign.royalBlue)
  }
}

private enum IOSRootSection: String, CaseIterable {
  case today
  case search

  var title: String {
    switch self {
    case .today: "Idag"
    case .search: "Sök"
    }
  }

  var systemImage: String {
    switch self {
    case .today: "sun.max.fill"
    case .search: "magnifyingglass"
    }
  }
}

private struct IOSCompactTabBar: View {
  @Binding var selectedSection: IOSRootSection

  var body: some View {
    HStack(spacing: 6) {
      ForEach(IOSRootSection.allCases, id: \.self) { section in
        Button {
          withAnimation(.smooth(duration: 0.22)) {
            selectedSection = section
          }
        } label: {
          Label(section.title, systemImage: section.systemImage)
            .font(.caption.weight(.semibold))
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minWidth: 82)
            .foregroundStyle(selectedSection == section ? OrderDesign.royalBlue : .white.opacity(0.84))
            .background {
              Capsule()
                .fill(selectedSection == section ? OrderDesign.goldenYellow : .white.opacity(0.10))
            }
        }
        .buttonStyle(.plain)
      }
    }
    .padding(6)
    .background(.ultraThinMaterial, in: Capsule())
    .overlay {
      Capsule()
        .stroke(.white.opacity(0.18), lineWidth: 1)
    }
    .padding(.bottom, 4)
  }
}

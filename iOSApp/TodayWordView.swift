import SwiftUI
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

struct IOSTodayWordView: View {
  let store: VocabularyStore
  @State private var alternateOffset = 0

  private var provider: WordOfDayProvider {
    WordOfDayProvider(entries: entries)
  }

  private var entries: [VocabularyEntry] {
    store.entries.isEmpty ? VocabularyEntry.fallbackEntries : store.entries
  }

  private var entry: VocabularyEntry {
    let index = (provider.index() + alternateOffset) % entries.count
    return entries[index]
  }

  private var isTodayEntry: Bool {
    alternateOffset == 0
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        OrderAppBackground()

        ViewThatFits(in: .vertical) {
          IOSTodayWordContent(
            entry: entry,
            isTodayEntry: isTodayEntry,
            loadErrorDescription: store.loadErrorDescription,
            variant: .regular,
            onNewWord: showNewWord,
            onToday: showToday
          )

          IOSTodayWordContent(
            entry: entry,
            isTodayEntry: isTodayEntry,
            loadErrorDescription: store.loadErrorDescription,
            variant: .compact,
            onNewWord: showNewWord,
            onToday: showToday
          )

          IOSTodayWordContent(
            entry: entry,
            isTodayEntry: isTodayEntry,
            loadErrorDescription: nil,
            variant: .tight,
            onNewWord: showNewWord,
            onToday: showToday
          )
        }
        .padding(.horizontal, max(18, min(28, proxy.size.width * 0.055)))
        .padding(.top, 12)
        .padding(.bottom, 10)
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
      }
    }
    .toolbar(.hidden, for: .navigationBar)
  }

  private func showNewWord() {
    guard entries.count > 1 else { return }
    withAnimation(.smooth(duration: 0.28)) {
      alternateOffset = (alternateOffset + 1) % entries.count
      if alternateOffset == 0 {
        alternateOffset = 1
      }
    }
  }

  private func showToday() {
    withAnimation(.smooth(duration: 0.24)) {
      alternateOffset = 0
    }
  }
}

private struct IOSTodayWordContent: View {
  let entry: VocabularyEntry
  let isTodayEntry: Bool
  let loadErrorDescription: String?
  let variant: IOSTodayLayoutVariant
  let onNewWord: () -> Void
  let onToday: () -> Void

  private var explanation: String {
    let sentence = EntryFormatter.sentenceTrimmed(entry.forklaringSV, maxCharacters: variant.explanationCharacters)
    if !sentence.isEmpty {
      return sentence
    }
    return EntryFormatter.trimmed(entry.forklaringSV, maxCharacters: variant.explanationCharacters)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: variant.outerSpacing) {
      HStack(alignment: .center, spacing: 10) {
        VStack(alignment: .leading, spacing: 4) {
          Text(isTodayEntry ? "Dagens forskningsord" : "Utforskat forskningsord")
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(OrderDesign.goldenYellow)
            .lineLimit(1)

          Text(Date().formatted(date: .abbreviated, time: .omitted))
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.66))
            .lineLimit(1)
        }

        Spacer(minLength: 8)

        if !isTodayEntry {
          Button(action: onToday) {
            Image(systemName: "sun.max")
              .font(.caption.weight(.bold))
              .frame(width: 30, height: 30)
          }
          .buttonStyle(.plain)
          .foregroundStyle(.white)
          .background(.white.opacity(0.12), in: Circle())
          .accessibilityLabel("Visa dagens ord")
        }

        Button(action: onNewWord) {
          Label("Nytt", systemImage: "sparkles")
            .font(.caption.weight(.bold))
            .lineLimit(1)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .foregroundStyle(OrderDesign.royalBlue)
        .background(OrderDesign.goldenYellow, in: Capsule())
        .accessibilityLabel("Visa ett nytt ord")
      }

      VStack(alignment: .leading, spacing: variant.wordSpacing) {
        OrderDesign.goldRule

        Text(entry.svenska)
          .font(.system(size: variant.wordSize, weight: .semibold, design: .serif))
          .foregroundStyle(.white)
          .textSelection(.enabled)
          .lineLimit(variant.wordLineLimit)
          .minimumScaleFactor(0.42)
          .allowsTightening(true)
          .frame(maxWidth: .infinity, alignment: .leading)

        Text(entry.suomeksi)
          .font(.system(size: variant.translationSize, weight: .medium, design: .default))
          .foregroundStyle(OrderDesign.goldenYellow.opacity(0.94))
          .lineLimit(2)
          .minimumScaleFactor(0.60)
          .textSelection(.enabled)
      }
      .padding(variant.heroPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .fill(.white.opacity(0.10))
          .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
              .stroke(.white.opacity(0.18), lineWidth: 1)
          )
      }

      if variant.showsMetadata {
        HStack(spacing: 8) {
          IOSTodayChip(title: "Ordklass", value: entry.ordklass, systemImage: "textformat")
          IOSTodayChip(title: "Område", value: entry.omrade, systemImage: "building.columns")
        }
      }

      VStack(alignment: .leading, spacing: variant.descriptionSpacing) {
        Text(entry.kortForklaringSV.isEmpty ? "-" : entry.kortForklaringSV)
          .font(.system(size: variant.shortDescriptionSize, weight: .semibold, design: .default))
          .foregroundStyle(.white)
          .lineLimit(variant.shortLineLimit)
          .minimumScaleFactor(0.62)
          .fixedSize(horizontal: false, vertical: true)
          .textSelection(.enabled)

        Text(explanation.isEmpty ? entry.kortForklaringSV : explanation)
          .font(.system(size: variant.explanationSize, weight: .regular, design: .serif))
          .lineSpacing(variant.lineSpacing)
          .foregroundStyle(.white.opacity(0.78))
          .lineLimit(variant.explanationLineLimit)
          .minimumScaleFactor(0.72)
          .fixedSize(horizontal: false, vertical: true)
          .textSelection(.enabled)

        if variant.showsSource, let domain = entry.sourceDomain {
          Label(domain, systemImage: "link")
            .font(.caption2.weight(.medium))
            .foregroundStyle(.white.opacity(0.56))
            .lineLimit(1)
            .truncationMode(.middle)
        }
      }
      .padding(variant.descriptionPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(OrderDesign.midnightBlue.opacity(0.52))
          .overlay(alignment: .topLeading) {
            Rectangle()
              .fill(OrderDesign.goldenYellow)
              .frame(height: 3)
          }
          .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
          .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
              .stroke(.white.opacity(0.13), lineWidth: 1)
          )
      }

      if let loadErrorDescription {
        Label(loadErrorDescription, systemImage: "exclamationmark.triangle")
          .font(.caption2)
          .foregroundStyle(.white.opacity(0.66))
          .lineLimit(2)
      }

      Spacer(minLength: 0)
    }
  }
}

private struct IOSTodayChip: View {
  let title: String
  let value: String
  let systemImage: String

  var body: some View {
    Label {
      VStack(alignment: .leading, spacing: 1) {
        Text(title)
          .font(.caption2.weight(.semibold))
          .foregroundStyle(OrderDesign.goldenYellow.opacity(0.85))
          .lineLimit(1)
        Text(value.isEmpty ? "-" : value)
          .font(.caption.weight(.medium))
          .foregroundStyle(.white.opacity(0.84))
          .lineLimit(2)
          .minimumScaleFactor(0.72)
          .truncationMode(.tail)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    } icon: {
      Image(systemName: systemImage)
        .foregroundStyle(OrderDesign.goldenYellow)
        .frame(width: 16)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 9)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

private enum IOSTodayLayoutVariant {
  case regular
  case compact
  case tight

  var outerSpacing: CGFloat {
    switch self {
    case .regular: 14
    case .compact: 11
    case .tight: 9
    }
  }

  var wordSpacing: CGFloat {
    switch self {
    case .regular: 14
    case .compact: 10
    case .tight: 8
    }
  }

  var descriptionSpacing: CGFloat {
    switch self {
    case .regular: 12
    case .compact: 9
    case .tight: 7
    }
  }

  var heroPadding: EdgeInsets {
    switch self {
    case .regular: EdgeInsets(top: 22, leading: 22, bottom: 24, trailing: 22)
    case .compact: EdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)
    case .tight: EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
    }
  }

  var descriptionPadding: EdgeInsets {
    switch self {
    case .regular: EdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)
    case .compact: EdgeInsets(top: 15, leading: 16, bottom: 15, trailing: 16)
    case .tight: EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
    }
  }

  var wordSize: CGFloat {
    switch self {
    case .regular: 58
    case .compact: 48
    case .tight: 39
    }
  }

  var translationSize: CGFloat {
    switch self {
    case .regular: 24
    case .compact: 21
    case .tight: 18
    }
  }

  var shortDescriptionSize: CGFloat {
    switch self {
    case .regular: 22
    case .compact: 19
    case .tight: 17
    }
  }

  var explanationSize: CGFloat {
    switch self {
    case .regular: 18
    case .compact: 16
    case .tight: 14
    }
  }

  var lineSpacing: CGFloat {
    switch self {
    case .regular: 4
    case .compact: 3
    case .tight: 2
    }
  }

  var wordLineLimit: Int {
    switch self {
    case .regular: 3
    case .compact: 2
    case .tight: 2
    }
  }

  var shortLineLimit: Int {
    switch self {
    case .regular: 2
    case .compact: 2
    case .tight: 1
    }
  }

  var explanationLineLimit: Int {
    switch self {
    case .regular: 6
    case .compact: 5
    case .tight: 4
    }
  }

  var explanationCharacters: Int {
    switch self {
    case .regular: 230
    case .compact: 170
    case .tight: 120
    }
  }

  var showsMetadata: Bool {
    self != .tight
  }

  var showsSource: Bool {
    self == .regular
  }
}

#Preview {
  IOSTodayWordView(store: .init(entries: VocabularyEntry.fallbackEntries))
}

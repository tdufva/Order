import SwiftUI
 #if canImport(SwedishWordCore)
import SwedishWordCore
 #endif

struct IOSSearchView: View {
  let entries: [VocabularyEntry]
  @State private var query = ""

  private var results: [VocabularyEntry] {
    VocabularySearch.results(matching: query, in: entries)
  }

  var body: some View {
    List(results) { entry in
      NavigationLink {
        IOSEntryDetailView(entry: entry)
      } label: {
        HStack(alignment: .top, spacing: 10) {
          Capsule()
            .fill(OrderDesign.goldenYellow)
            .frame(width: 4)
            .padding(.vertical, 3)

          VStack(alignment: .leading, spacing: 4) {
            Text(entry.svenska)
              .font(.headline)
              .foregroundStyle(.white)
              .lineLimit(2)
              .minimumScaleFactor(0.82)
            Text(entry.suomeksi)
              .font(.subheadline)
              .foregroundStyle(OrderDesign.goldenYellow.opacity(0.90))
              .lineLimit(1)
              .truncationMode(.tail)
            Text(entry.kortForklaringSV)
              .font(.caption)
              .foregroundStyle(.white.opacity(0.68))
              .lineLimit(2)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
      }
      .listRowBackground(Color.white.opacity(0.08))
      .listRowSeparatorTint(.white.opacity(0.12))
    }
    .navigationTitle("Sök")
    .navigationBarTitleDisplayMode(.inline)
    .searchable(text: $query, prompt: "Svenska, suomeksi, område")
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(OrderAppBackground())
    .overlay {
      if results.isEmpty {
        ContentUnavailableView("Inga träffar", systemImage: "magnifyingglass", description: Text("Försök med ett annat ord, område eller begrepp."))
          .foregroundStyle(.white)
      }
    }
  }
}

private struct IOSEntryDetailView: View {
  let entry: VocabularyEntry

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        VStack(alignment: .leading, spacing: 18) {
          Text(entry.svenska)
            .font(.largeTitle)
            .fontDesign(.serif)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .textSelection(.enabled)
            .lineLimit(3)
            .minimumScaleFactor(0.58)
            .allowsTightening(true)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text(entry.suomeksi)
            .font(.title3)
            .foregroundStyle(.white.opacity(0.82))
            .textSelection(.enabled)
            .lineLimit(2)

          OrderDesign.goldRule
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OrderDesign.royalBlue, in: RoundedRectangle(cornerRadius: OrderDesign.cornerRadius, style: .continuous))

        VStack(alignment: .leading, spacing: 8) {
          IOSDetailMetadataRow(title: "Ordklass", value: entry.ordklass)
          IOSDetailMetadataRow(title: "Område", value: entry.omrade)
        }
      .font(.callout)
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: OrderDesign.cornerRadius, style: .continuous))

        VStack(alignment: .leading, spacing: 10) {
          Text(entry.kortForklaringSV)
          .font(.title3)
          .foregroundStyle(.white)
          .fixedSize(horizontal: false, vertical: true)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)

        Text(entry.forklaringSV)
          .foregroundStyle(.white.opacity(0.75))
          .fixedSize(horizontal: false, vertical: true)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(OrderDesign.midnightBlue.opacity(0.52), in: RoundedRectangle(cornerRadius: OrderDesign.cornerRadius, style: .continuous))

        if let url = entry.sourceURL {
          Link(destination: url) {
            Label(entry.sourceDomain ?? "Källa", systemImage: "link")
              .lineLimit(1)
              .truncationMode(.middle)
          }
          .buttonStyle(.bordered)
          .tint(OrderDesign.goldenYellow)
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(maxWidth: .infinity)
    }
    .navigationTitle(entry.svenska)
    .navigationBarTitleDisplayMode(.inline)
    .background(OrderAppBackground())
  }
}

private struct IOSDetailMetadataRow: View {
  let title: String
  let value: String

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      Text(title)
        .foregroundStyle(OrderDesign.goldenYellow.opacity(0.82))
        .frame(width: 72, alignment: .leading)
      Text(value.isEmpty ? "-" : value)
        .fontWeight(.medium)
        .foregroundStyle(.white.opacity(0.86))
        .lineLimit(3)
        .minimumScaleFactor(0.82)
        .truncationMode(.tail)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

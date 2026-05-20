import Foundation

public enum VocabularyStoreError: Error, Equatable, LocalizedError {
  case missingBundledCSV
  case emptyCSV
  case missingRequiredColumns([String])

  public var errorDescription: String? {
    switch self {
    case .missingBundledCSV:
      "Det gick inte att hitta vocabulary.csv i appens resurser."
    case .emptyCSV:
      "CSV-filen innehåller inga ordrader."
    case .missingRequiredColumns(let columns):
      "CSV-filen saknar kolumner: \(columns.joined(separator: ", "))."
    }
  }
}

public struct VocabularyStore: Sendable {
  public let entries: [VocabularyEntry]
  public let loadErrorDescription: String?

  public var isUsingFallback: Bool {
    loadErrorDescription != nil
  }

  public init(entries: [VocabularyEntry], loadErrorDescription: String? = nil) {
    if entries.isEmpty {
      self.entries = VocabularyEntry.fallbackEntries
      self.loadErrorDescription = loadErrorDescription ?? VocabularyStoreError.emptyCSV.localizedDescription
    } else {
      self.entries = entries
      self.loadErrorDescription = loadErrorDescription
    }
  }

  public static func bundledWithFallback() -> VocabularyStore {
    do {
      return try bundled()
    } catch {
      return VocabularyStore(
        entries: VocabularyEntry.fallbackEntries,
        loadErrorDescription: error.localizedDescription
      )
    }
  }

  public static func bundled() throws -> VocabularyStore {
    guard let url = resourceBundle.url(forResource: "vocabulary", withExtension: "csv")
      ?? resourceBundle.url(forResource: "vocabulary", withExtension: "csv", subdirectory: "Resources") else {
      throw VocabularyStoreError.missingBundledCSV
    }
    return try load(from: url)
  }

  public static func load(from url: URL) throws -> VocabularyStore {
    let contents = try String(contentsOf: url, encoding: .utf8)
    let entries = try parseEntries(fromCSVString: contents)
    return VocabularyStore(entries: entries)
  }

  public static func store(fromCSVString contents: String) -> VocabularyStore {
    do {
      return VocabularyStore(entries: try parseEntries(fromCSVString: contents))
    } catch {
      return VocabularyStore(
        entries: VocabularyEntry.fallbackEntries,
        loadErrorDescription: error.localizedDescription
      )
    }
  }

  public static func parseEntries(fromCSVString contents: String) throws -> [VocabularyEntry] {
    let rows = try CSVParser().parse(contents)
      .filter { !$0.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } }

    guard let headerRow = rows.first else {
      throw VocabularyStoreError.emptyCSV
    }

    let headers = headerRow.map(Self.normalizedHeader)
    let requiredHeaders = [
      "svenska",
      "ordklass",
      "förklaring_sv",
      "kort_förklaring_sv",
      "suomeksi",
      "område",
      "källa_url"
    ]

    let missingHeaders = requiredHeaders.filter { requiredHeader in
      !headers.contains(requiredHeader)
    }

    guard missingHeaders.isEmpty else {
      throw VocabularyStoreError.missingRequiredColumns(missingHeaders)
    }

    let headerIndexes = Dictionary(uniqueKeysWithValues: headers.enumerated().map { ($0.element, $0.offset) })

    let dataRows = rows.dropFirst()
    let entries = dataRows.enumerated().compactMap { offset, row -> VocabularyEntry? in
      func value(_ header: String) -> String {
        guard let index = headerIndexes[header], row.indices.contains(index) else {
          return ""
        }
        return row[index].trimmingCharacters(in: .whitespacesAndNewlines)
      }

      let svenska = value("svenska")
      guard !svenska.isEmpty else {
        return nil
      }

      let parsedID = Int(value("id"))
      return VocabularyEntry(
        id: parsedID ?? offset,
        svenska: svenska,
        ordklass: value("ordklass"),
        forklaringSV: value("förklaring_sv"),
        kortForklaringSV: value("kort_förklaring_sv"),
        suomeksi: value("suomeksi"),
        omrade: value("område"),
        kallaURL: value("källa_url")
      )
    }

    guard !entries.isEmpty else {
      throw VocabularyStoreError.emptyCSV
    }

    return entries
  }

  private static func normalizedHeader(_ header: String) -> String {
    var normalized = header.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if normalized.first == "\u{FEFF}" {
      normalized.removeFirst()
    }

    switch normalized {
    case "forklaring_sv":
      return "förklaring_sv"
    case "kort_forklaring_sv":
      return "kort_förklaring_sv"
    case "omrade":
      return "område"
    case "kalla_url":
      return "källa_url"
    default:
      return normalized
    }
  }
}

private final class VocabularyBundleToken {}

private var resourceBundle: Bundle {
  #if SWIFT_PACKAGE
  return Bundle.module
  #else
  return Bundle(for: VocabularyBundleToken.self)
  #endif
}

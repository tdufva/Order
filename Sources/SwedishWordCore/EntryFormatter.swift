import Foundation

public enum EntryFormatter {
  public static func fullEntry(_ entry: VocabularyEntry) -> String {
    """
    \(entry.svenska) (\(entry.ordklass))
    Suomeksi: \(entry.suomeksi)
    Område: \(entry.omrade)

    Kort förklaring:
    \(entry.kortForklaringSV)

    Förklaring:
    \(entry.forklaringSV)

    Källa:
    \(entry.kallaURL)
    """
  }

  public static func trimmed(_ value: String, maxCharacters: Int) -> String {
    guard maxCharacters > 0 else { return "" }
    let cleaned = singleLine(value)

    guard cleaned.count > maxCharacters else {
      return cleaned
    }

    let prefix = String(cleaned.prefix(maxCharacters)).trimmingCharacters(in: .whitespacesAndNewlines)
    if let lastWhitespace = prefix.lastIndex(where: { $0.isWhitespace }) {
      let distance = prefix.distance(from: prefix.startIndex, to: lastWhitespace)
      if distance > max(8, maxCharacters / 2) {
        return String(prefix[..<lastWhitespace]) + "..."
      }
    }
    return prefix + "..."
  }

  public static func sentenceTrimmed(_ value: String, maxCharacters: Int) -> String {
    guard maxCharacters > 0 else { return "" }
    let cleaned = singleLine(value)

    guard cleaned.count > maxCharacters else {
      return cleaned
    }

    var result = ""
    cleaned.enumerateSubstrings(
      in: cleaned.startIndex..<cleaned.endIndex,
      options: [.bySentences]
    ) { substring, _, _, stop in
      guard let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines),
            !sentence.isEmpty else {
        return
      }

      let candidate = result.isEmpty ? sentence : "\(result) \(sentence)"
      if candidate.count <= maxCharacters {
        result = candidate
      } else {
        stop = true
      }
    }

    guard !result.isEmpty else {
      return ""
    }

    let ellipsis = " ..."
    if result.count + ellipsis.count <= maxCharacters {
      return result + ellipsis
    }
    return result
  }

  public static func menuTitle(_ value: String, maxCharacters: Int = 30) -> String {
    trimmed(value, maxCharacters: maxCharacters)
  }

  private static func singleLine(_ value: String) -> String {
    value.split(whereSeparator: \.isWhitespace).joined(separator: " ")
  }
}

public enum VocabularySearch {
  public static func results(matching query: String, in entries: [VocabularyEntry]) -> [VocabularyEntry] {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
      .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)

    guard !normalizedQuery.isEmpty else {
      return entries
    }

    return entries.filter { entry in
      searchableText(for: entry).contains(normalizedQuery)
    }
  }

  private static func searchableText(for entry: VocabularyEntry) -> String {
    [
      entry.svenska,
      entry.suomeksi,
      entry.ordklass,
      entry.omrade,
      entry.kortForklaringSV,
      entry.forklaringSV
    ]
    .joined(separator: " ")
    .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
  }
}

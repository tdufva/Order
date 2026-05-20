import Foundation

public struct VocabularyEntry: Identifiable, Hashable, Codable, Sendable {
  public let id: Int
  public let svenska: String
  public let ordklass: String
  public let forklaringSV: String
  public let kortForklaringSV: String
  public let suomeksi: String
  public let omrade: String
  public let kallaURL: String

  public init(
    id: Int,
    svenska: String,
    ordklass: String,
    forklaringSV: String,
    kortForklaringSV: String,
    suomeksi: String,
    omrade: String,
    kallaURL: String
  ) {
    self.id = id
    self.svenska = svenska
    self.ordklass = ordklass
    self.forklaringSV = forklaringSV
    self.kortForklaringSV = kortForklaringSV
    self.suomeksi = suomeksi
    self.omrade = omrade
    self.kallaURL = kallaURL
  }

  public var sourceURL: URL? {
    let trimmed = kallaURL.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    return URL(string: trimmed)
  }

  public var sourceDomain: String? {
    guard let host = sourceURL?.host(percentEncoded: false), !host.isEmpty else {
      return nil
    }
    return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
  }
}

public extension VocabularyEntry {
  static let fallback = VocabularyEntry(
    id: 0,
    svenska: "kunskapande",
    ordklass: "substantiv",
    forklaringSV: "Kunskapande beskriver hur kunskap blir till genom praktik, material, språk och relationer. Ordet används ofta i forskning där lärande och skapande förstås som sammanvävda processer.",
    kortForklaringSV: "Hur kunskap blir till.",
    suomeksi: "tiedonmuodostus",
    omrade: "humanistisk och konstnärlig forskning",
    kallaURL: ""
  )

  static let fallbackEntries: [VocabularyEntry] = [
    .fallback,
    VocabularyEntry(
      id: 1,
      svenska: "situering",
      ordklass: "substantiv",
      forklaringSV: "Situering betonar att kunskap alltid formas i en viss plats, kropp, historia och praktik. Begreppet hjälper forskaren att synliggöra sin position och sina villkor.",
      kortForklaringSV: "Kunskapens plats och position.",
      suomeksi: "paikantuminen",
      omrade: "feministisk forskning",
      kallaURL: ""
    ),
    VocabularyEntry(
      id: 2,
      svenska: "materialitet",
      ordklass: "substantiv",
      forklaringSV: "Materialitet används för att beskriva hur material, ting, miljöer och kroppar deltar i betydelseskapande. Det flyttar uppmärksamheten från enbart mänskliga avsikter till relationer mellan många aktörer.",
      kortForklaringSV: "Materialens betydelse.",
      suomeksi: "materiaalisuus",
      omrade: "nymaterialistisk teori",
      kallaURL: ""
    )
  ]
}

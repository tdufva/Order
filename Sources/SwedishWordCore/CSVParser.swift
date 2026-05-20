import Foundation

public enum CSVParserError: Error, Equatable, LocalizedError {
  case unterminatedQuotedField

  public var errorDescription: String? {
    switch self {
    case .unterminatedQuotedField:
      "CSV-filen innehåller ett citerat fält som inte avslutas."
    }
  }
}

public struct CSVParser: Sendable {
  public init() {}

  public func parse(_ contents: String, delimiter requestedDelimiter: Character? = nil) throws -> [[String]] {
    let delimiter = requestedDelimiter ?? Self.detectDelimiter(in: contents)
    var rows: [[String]] = []
    var row: [String] = []
    var field = ""
    var isInsideQuotes = false
    var rowStarted = false
    var fieldStarted = false

    var index = contents.startIndex
    while index < contents.endIndex {
      let character = contents[index]

      if character == "\u{FEFF}", rows.isEmpty, row.isEmpty, field.isEmpty, !rowStarted {
        index = contents.index(after: index)
        continue
      }

      if isInsideQuotes {
        if character == "\"" {
          let nextIndex = contents.index(after: index)
          if nextIndex < contents.endIndex, contents[nextIndex] == "\"" {
            field.append("\"")
            index = contents.index(after: nextIndex)
          } else {
            isInsideQuotes = false
            index = nextIndex
          }
        } else {
          field.append(character)
          index = contents.index(after: index)
        }
        continue
      }

      if character == "\"" {
        if field.isEmpty {
          isInsideQuotes = true
          fieldStarted = true
          rowStarted = true
        } else {
          field.append(character)
        }
      } else if character == delimiter {
        row.append(field)
        field.removeAll(keepingCapacity: true)
        fieldStarted = false
        rowStarted = true
      } else if character.isNewline {
        if rowStarted || fieldStarted || !row.isEmpty {
          row.append(field)
          rows.append(row)
        }
        row.removeAll(keepingCapacity: true)
        field.removeAll(keepingCapacity: true)
        rowStarted = false
        fieldStarted = false

        if character == "\r" {
          let nextIndex = contents.index(after: index)
          if nextIndex < contents.endIndex, contents[nextIndex] == "\n" {
            index = nextIndex
          }
        }
      } else {
        field.append(character)
        fieldStarted = true
        rowStarted = true
      }

      index = contents.index(after: index)
    }

    if isInsideQuotes {
      throw CSVParserError.unterminatedQuotedField
    }

    if rowStarted || fieldStarted || !row.isEmpty {
      row.append(field)
      rows.append(row)
    }

    return rows
  }

  private static func detectDelimiter(in contents: String) -> Character {
    var commaCount = 0
    var semicolonCount = 0
    var isInsideQuotes = false
    var index = contents.startIndex

    while index < contents.endIndex {
      let character = contents[index]
      if character == "\"" {
        isInsideQuotes.toggle()
      } else if !isInsideQuotes {
        if character == "," {
          commaCount += 1
        } else if character == ";" {
          semicolonCount += 1
        } else if character.isNewline {
          break
        }
      }
      index = contents.index(after: index)
    }

    return semicolonCount > commaCount ? ";" : ","
  }
}


import Foundation


extension String {
    
    var trimmingWhiteSpaces: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var removingNewLine: String {
        replacingOccurrences(of: "\n", with: "")
    }
    
    var replacingNewLineWithSpace: String {
        replacingOccurrences(of: "\n", with: " ")
    }
}

extension String.StringInterpolation {
    
  mutating func appendInterpolation<T>(maybe: T?) {
    if let value = maybe {
      appendInterpolation(value)
    } else {
      appendLiteral("nil")
    }
  }
}

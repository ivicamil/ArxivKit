
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

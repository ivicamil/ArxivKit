
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
    
    var removingNonEnglishCharacters: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
        return mutableString as String
    }
}

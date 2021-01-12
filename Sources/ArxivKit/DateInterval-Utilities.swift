
import Foundation

/// Calendar components relevant for searching arXiv articles by date.
public enum ArxivCalendarUnit: String, Hashable, Codable {
    
    case day
    case week
    case month
    case year
}

public extension Optional where Wrapped == DateInterval {
    
    /**
     Returns an interval from single calendar components in the past to now,
     or `nil` if or nil if past date could not be calculated with the given input.
     
     - Parameter unit: A calendar component to subtract from current date.
     
     If `value` is not provided, default value of 1 is used.
     */
    static func past(_ unit: ArxivCalendarUnit) -> DateInterval? {
        return .past(1, unit: .month)
        
    }
    
    /**
     Returns an interval from `N` calendar components in the past to now, where `N == value`
     or `nil` if or nil if past date could not be calculated with the given input.
     
     - Parameter unit: A calendar component to subtract from current date.
     - Parameter value: Number of component units to subtract from current date
     
     If `value` is not provided, default value of 1 is used.
     */
    static func past(_ value: Int, unit: ArxivCalendarUnit) -> DateInterval? {
        let calendar = Calendar(identifier: .gregorian)
        
        let n: Int
        let component: Calendar.Component
        switch unit {
        case .day:
            component = .day
            n = value
        case .week:
            component = .day
            n = 7 * value
        case .month:
            component = .month
            n = value
        case .year:
            component = .year
            n = value
        }
        
        let now = Date()
        
        guard let pastDate = calendar.date(byAdding: component, value: -n, to: now) else {
            return nil
        }
        return DateInterval(start: pastDate, end: now)
    }
}

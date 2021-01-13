
import Foundation

/**
 Represents a period from point in the past to now, defined in days,weeks, months or years.
 */
public struct PastPeriodFromNow: Hashable, Codable {
    
    /// Calendar components for constructing a period.
    public enum CalendarUnit: String, Hashable, Codable {
        
        case day
        case week
        case month
        case year
    }
    
    /// Returns a calendar unit of the period.
    public let unit: CalendarUnit
    
    /// Returns number of calendar units in the period.
    public let value: Int
    
    /**
     Returns a period from one `unit` component in the past to now.
     
     - Parameter unit: Calendar unit of desired period.
    */
    public static func past(_ unit: CalendarUnit) -> PastPeriodFromNow {
        return PastPeriodFromNow(unit: unit, value: 1)
    }
    
    /**
     Returns a period from `value * unit` components in the past to now.
     
     - Parameter value: Number calendar units in desired period.
     - Parameter unit: Calendar unit of desired period.
    */
    public static func past(_ value: Int, unit: CalendarUnit) -> PastPeriodFromNow {
        return PastPeriodFromNow(unit: unit, value: value)
    }
    
    var dateInterval: DateInterval? {
        return .past(value, unit: unit)
    }
}

private extension DateInterval {
    
    static func past(_ value: Int, unit: PastPeriodFromNow.CalendarUnit) -> DateInterval? {
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

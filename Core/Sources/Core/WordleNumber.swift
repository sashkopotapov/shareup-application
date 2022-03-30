
import Foundation

public func wordleNumberFromDate(dayDate: DayDate) -> Int? {
    var dateComponents = DateComponents()
    dateComponents.year = dayDate.year
    dateComponents.month = dayDate.month
    dateComponents.day = dayDate.day
    let userCalendar = Calendar(identifier: .gregorian)
    
    guard let date = userCalendar.date(from: dateComponents) else { return nil }
    
    let initialWordleDay = Date(timeIntervalSince1970: 1624050001)
    let fromDate = Calendar.current.startOfDay(for: initialWordleDay)
    let toDate = Calendar.current.startOfDay(for: date)
    let numberOfDays = Calendar.current.dateComponents([.day], from: fromDate, to: toDate)
    
    return numberOfDays.day ?? nil
}

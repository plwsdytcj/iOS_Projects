import Foundation.NSDate

let dateFormatter = DateFormatter()

class Chat {
    let user: User
    var lastMessageText: String
    var lastMessageSentDate: Date
    var lastMessageSentDateString: String {
        return formatDate(lastMessageSentDate)
    }
    var loadedMessages = [[Message]]()
    var unreadMessageCount: Int = 0 // subtacted from total when read
    var hasUnloadedMessages = false
    var draft = ""

    init(user: User, lastMessageText: String, lastMessageSentDate: Date) {
        self.user = user
        self.lastMessageText = lastMessageText
        self.lastMessageSentDate = lastMessageSentDate
    }

    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current

        let last18hours = (-18*60*60 < date.timeIntervalSinceNow)
        let isToday = calendar.isDateInToday(date)
        let isLast7Days = ((calendar as NSCalendar).compare(Date(timeIntervalSinceNow: -7*24*60*60), to: date, toUnitGranularity: .day) == ComparisonResult.orderedAscending)

        if last18hours || isToday {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
        } else if isLast7Days {
            dateFormatter.dateFormat = "ccc"
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
        }
        return dateFormatter.string(from: date)
    }
}

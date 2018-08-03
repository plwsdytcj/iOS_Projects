import Foundation.NSDate

class Message {
    let incoming: Bool
    let text: String
    let sentDate: Date

    init(incoming: Bool, text: String, sentDate: Date) {
        self.incoming = incoming
        self.text = text
        self.sentDate = sentDate
    }
}

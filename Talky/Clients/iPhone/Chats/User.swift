import Foundation.NSString

class User : NSObject {
    let ID: UInt
    var username: String
    dynamic var firstName: String
    dynamic var lastName: String
    var name: String {
        return firstName + " " + lastName
    }
    var initials: String? {
        var initials: String?
        for name in [firstName, lastName] {
            let initial = name.substring(to: name.characters.index(name.startIndex, offsetBy: 1))
            if initial.lengthOfBytes(using: String.Encoding.nextstep) > 0 {
                initials = initials == nil ? initial : initials! + initial
            }
        }
        return initials
    }

    init(ID: UInt, username: String, firstName: String, lastName: String) {
        self.ID = ID
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
    }

    func pictureName() -> String? {
        return ID > 21 ? nil : "User\(ID).jpg"
    }
}

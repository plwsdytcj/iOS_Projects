import UIKit

class UserPictureImageView: UIImageView {
    fileprivate let userNameInitialsLabel: UILabel

    override init(frame: CGRect) {
        userNameInitialsLabel = UILabel(frame: CGRect.zero)
        super.init(frame: frame)

        backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1)
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true

        userNameInitialsLabel.font = UIFont.systemFont(ofSize: frame.width/2+1)
        userNameInitialsLabel.textAlignment = .center
        userNameInitialsLabel.textColor = .white
        addSubview(userNameInitialsLabel)

        userNameInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: userNameInitialsLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: userNameInitialsLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -1))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithUser(_ user: User) {
        if let pictureName = user.pictureName() {
            image = UIImage(named: pictureName)
            userNameInitialsLabel.isHidden = true
            return
        }
        if let initials = user.initials {
            image = nil
            userNameInitialsLabel.isHidden = false
            userNameInitialsLabel.text = initials
            return
        }
        image = UIImage(named: "User0")
        userNameInitialsLabel.isHidden = true
    }
}

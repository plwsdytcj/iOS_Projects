import UIKit

let chatTableViewCellHeight: CGFloat = 72
let chatTableViewCellInsetLeft = chatTableViewCellHeight + 8

class ChatTableViewCell: UITableViewCell {
    let userPictureImageView: UserPictureImageView
    let userNameLabel: UILabel
    let lastMessageTextLabel: UILabel
    let lastMessageSentDateLabel: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        userPictureImageView = UserPictureImageView(frame: CGRect(x: 8, y: (chatTableViewCellHeight-64)/2, width: 64, height: 64))

        userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.backgroundColor = .white
        userNameLabel.font = UIFont.systemFont(ofSize: 17)

        lastMessageTextLabel = UILabel(frame: CGRect.zero)
        lastMessageTextLabel.backgroundColor = .white
        lastMessageTextLabel.font = UIFont.systemFont(ofSize: 15)
        lastMessageTextLabel.numberOfLines = 2
        lastMessageTextLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)

        lastMessageSentDateLabel = UILabel(frame: CGRect.zero)
        lastMessageSentDateLabel.autoresizingMask = .flexibleLeftMargin
        lastMessageSentDateLabel.backgroundColor = .white
        lastMessageSentDateLabel.font = UIFont.systemFont(ofSize: 15)
        lastMessageSentDateLabel.textColor = lastMessageTextLabel.textColor

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userPictureImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(lastMessageTextLabel)
        contentView.addSubview(lastMessageSentDateLabel)

        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: chatTableViewCellInsetLeft))
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 6))

        lastMessageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageTextLabel, attribute: .left, relatedBy: .equal, toItem: userNameLabel, attribute: .left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageTextLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 28))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageTextLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -7))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageTextLabel, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -4))

        lastMessageSentDateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageSentDateLabel, attribute: .left, relatedBy: .equal, toItem: userNameLabel, attribute: .right, multiplier: 1, constant: 2))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageSentDateLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -7))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageSentDateLabel, attribute: .lastBaseline, relatedBy: .equal, toItem: userNameLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithChat(_ chat: Chat) {
        let user = chat.user
        userPictureImageView.configureWithUser(user)
        userNameLabel.text = user.name
        lastMessageTextLabel.text = chat.lastMessageText
        lastMessageSentDateLabel.text = chat.lastMessageSentDateString
    }
}

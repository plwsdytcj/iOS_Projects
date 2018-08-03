import UIKit

let incomingTag = 0, outgoingTag = 1
let bubbleTag = 8

class MessageBubbleTableViewCell: UITableViewCell {
    let bubbleImageView: UIImageView
    static let bubbleImage: (incoming: UIImage, incomingHighlighed: UIImage, outgoing: UIImage, outgoingHighlighed: UIImage) = {
        let maskOutgoing = UIImage(named: "MessageBubble")!
        let maskIncoming = UIImage(cgImage: maskOutgoing.cgImage!, scale: 2, orientation: .upMirrored)

        let capInsetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
        let capInsetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)

        let incoming = maskIncoming.imageWithRed(229/255, green: 229/255, blue: 234/255, alpha: 1).resizableImage(withCapInsets: capInsetsIncoming)
        let incomingHighlighted = maskIncoming.imageWithRed(206/255, green: 206/255, blue: 210/255, alpha: 1).resizableImage(withCapInsets: capInsetsIncoming)
        let outgoing = maskOutgoing.imageWithRed(43/255, green: 119/255, blue: 250/255, alpha: 1).resizableImage(withCapInsets: capInsetsOutgoing)
        let outgoingHighlighted = maskOutgoing.imageWithRed(32/255, green: 96/255, blue: 200/255, alpha: 1).resizableImage(withCapInsets: capInsetsOutgoing)

        return (incoming, incomingHighlighted, outgoing, outgoingHighlighted)
    }()
    let messageLabel: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        bubbleImageView = UIImageView(image: MessageBubbleTableViewCell.bubbleImage.incoming, highlightedImage: MessageBubbleTableViewCell.bubbleImage.incomingHighlighed)
        bubbleImageView.tag = bubbleTag
        bubbleImageView.isUserInteractionEnabled = true // #CopyMesage

        messageLabel = UILabel(frame: CGRect.zero)
        messageLabel.font = UIFont.systemFont(ofSize: ChatViewController.chatMessageFontSize)
        messageLabel.numberOfLines = 0
        messageLabel.isUserInteractionEnabled = false   // #CopyMessage

        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)

        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 4.5))
        bubbleImageView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: .width, relatedBy: .equal, toItem: messageLabel, attribute: .width, multiplier: 1, constant: 30))
        contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -4.5))

        bubbleImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: bubbleImageView, attribute: .centerX, multiplier: 1, constant: 3))
        bubbleImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: bubbleImageView, attribute: .centerY, multiplier: 1, constant: -0.5))
        messageLabel.preferredMaxLayoutWidth = 218
        bubbleImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .height, relatedBy: .equal, toItem: bubbleImageView, attribute: .height, multiplier: 1, constant: -15))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithMessage(_ message: Message) {
        messageLabel.text = message.text

        if message.incoming != (tag == incomingTag) {
            var layoutAttribute: NSLayoutAttribute
            var layoutConstant: CGFloat

            if message.incoming {
                tag = incomingTag
                bubbleImageView.image = MessageBubbleTableViewCell.bubbleImage.incoming
                bubbleImageView.highlightedImage = MessageBubbleTableViewCell.bubbleImage.incomingHighlighed
                messageLabel.textColor = .black
                layoutAttribute = .left
                layoutConstant = 10
            } else { // outgoing
                tag = outgoingTag
                bubbleImageView.image = MessageBubbleTableViewCell.bubbleImage.outgoing
                bubbleImageView.highlightedImage = MessageBubbleTableViewCell.bubbleImage.outgoingHighlighed
                messageLabel.textColor = .white
                layoutAttribute = .right
                layoutConstant = -10
            }

            let layoutConstraint: NSLayoutConstraint = bubbleImageView.constraints[1] // `messageLabel` CenterX
            layoutConstraint.constant = -layoutConstraint.constant

            let constraints: NSArray = contentView.constraints as NSArray
            let indexOfConstraint = constraints.indexOfObject (passingTest: { constraint, idx, stop in
                return ((constraint as AnyObject).firstItem as! UIView).tag == bubbleTag && (constraint.firstAttribute == NSLayoutAttribute.left || constraint.firstAttribute == NSLayoutAttribute.right)
            })
            contentView.removeConstraint(constraints[indexOfConstraint] as! NSLayoutConstraint)
            contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: layoutAttribute, relatedBy: .equal, toItem: contentView, attribute: layoutAttribute, multiplier: 1, constant: layoutConstant))
        }
    }

    // Highlight cell #CopyMessage
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleImageView.isHighlighted = selected
    }
}

extension UIImage {
    func imageWithRed(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.draw(in: rect)
        context?.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
        context?.setBlendMode(CGBlendMode.sourceAtop)
        context?.fill(rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

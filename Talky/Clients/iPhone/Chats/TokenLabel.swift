import UIKit

class TokenLabel: UILabel, UIKeyInput {
    weak var delegate: TokenLabelDelegate?

    override var text: String? {
        didSet {
            if let text = text, text.strip() != "" {
                let textSize = text.size(attributes: [NSFontAttributeName: font])
                frame.size = CGSize(width: textSize.width+8, height: textSize.height+6)
            } else {
                frame.size = .zero
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? textColor : .clear
        }
    }

    convenience init(origin: CGPoint) {
        self.init(frame: CGRect(origin: origin, size: .zero))
        font = UIFont.systemFont(ofSize: 15)
        highlightedTextColor = .white
        layer.cornerRadius = 4
        layer.masksToBounds = true
        textAlignment = .center
        textColor = UIColor(red: 18/255.0, green: 106/255.0, blue: 255/255.0, alpha: 1)
        isUserInteractionEnabled = true
        isHighlighted = false // sets background color
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder : Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            isHighlighted = true
            return true
        }
        return false
    }

    override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            isHighlighted = false
            return true
        }
        return false
    }

    // MARK: - UIResponder: Touch Events

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first!.location(in: self)
        if !isFirstResponder && !frame.contains(touchPoint) {
            isHighlighted = false
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isHighlighted {
            becomeFirstResponder()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = isFirstResponder
    }

    // MARK: - UIKeyInput

    var hasText : Bool {
        return text != nil && text != ""
    }

    func insertText(_ text: String) {
        if delegate != nil {
            delegate!.tokenLabel(self, didInsertText: text)
        }
    }

    func deleteBackward() {
        if delegate != nil {
            delegate!.tokenLabelDidDeleteBackward(self)
        }
    }

    // MARK: - UITextInputTraits

    var autocapitalizationType: UITextAutocapitalizationType {
        get { return .none } set { }
    }

    var autocorrectionType: UITextAutocorrectionType {
        get { return .no } set { }
    }

    var returnKeyType: UIReturnKeyType {
        get { return .next } set { }
    }
}

protocol TokenLabelDelegate: class {
    func tokenLabel(_ tokenLabel: TokenLabel, didInsertText text: String)
    func tokenLabelDidDeleteBackward(_ tokenLabel: TokenLabel)
}

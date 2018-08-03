import UIKit

class ToTextField: UITextField {
    // MARK: - UIResponder

    // Don't begin editing textView when swiping down keyboard
    override func nextResponder() -> UIResponder? {
        return super.next!.next
    }

    // MARK: - UITextField

    override init(frame: CGRect) {
        super.init(frame: frame)
        autocapitalizationType = .none
        autocorrectionType = .no
        autoresizingMask = .flexibleWidth
        clearButtonMode = .whileEditing
        font = UIFont.systemFont(ofSize: 15)
        returnKeyType = .next  // TODO: Remove when allowing multiple recipients
        let toLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 26, height: 23))
        toLabel.font = UIFont.systemFont(ofSize: 15)
        toLabel.text = "To:"
        toLabel.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1)
        leftView = toLabel
        leftViewMode = .always
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 15
        rect.origin.y -= 0.5
        return rect
    }
}

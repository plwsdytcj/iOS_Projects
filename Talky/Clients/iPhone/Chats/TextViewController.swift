import UIKit

class TextViewController: UIViewController {
    var textView: UITextView! { return (view as! UITextView) }

    override func loadView() {
        let textView = UITextView(frame: UIScreen.main.bounds, textContainer: nil)
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = .interactive
        view = textView
    }

    // MARK: - Keyboard Inset

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(TextViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    // Inset scroll views above keyboard
    func keyboardWillShow(_ notification: Notification) {
        let frameEnd = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeightEnd = view.convert(frameEnd, from: nil).size.height
        setTextViewBottomInset(keyboardHeightEnd)
    }

    func setTextViewBottomInset(_ insetBottom: CGFloat) {
        textView.contentInset.bottom = insetBottom
        textView.scrollIndicatorInsets.bottom = insetBottom
    }
}

import UIKit
import CodeInputView
import Networking

enum EnterCodeMethod : Int {
    case signup
    case login
    case email
}

class EnterCodeViewController: UIViewController, CodeInputViewDelegate {
    var method = EnterCodeMethod.signup
    var email: String

    init(method: EnterCodeMethod, email: String) {
        self.method = method
        self.email = email
        super.init(nibName: nil, bundle: nil)
        title = "Verify Email"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let noticeLabel = UILabel(frame: CGRect.zero)
        noticeLabel.numberOfLines = 2
        noticeLabel.text = "Enter the code sent to\n\(email)"
        noticeLabel.textAlignment = .center
        view.addSubview(noticeLabel)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: noticeLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: noticeLabel, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: noticeLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
        ])

        let codeInputView = CodeInputView(frame: CGRect(x: (view.frame.width-215)/2, y: 142, width: 215, height: 60))
        codeInputView.delegate = self
        codeInputView.tag = 17
        view.addSubview(codeInputView)
        codeInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: codeInputView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: codeInputView, attribute: .Top, relatedBy: .Equal, toItem: noticeLabel, attribute: .Bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: codeInputView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 215),
            NSLayoutConstraint(item: codeInputView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 60)
        ])
        codeInputView.becomeFirstResponder()
    }

    // MARK: - CodeInputViewDelegate

    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
        let HTTPMethod: String
        let path: String
        let loadingTitle: String
        let successCode: Int

        switch method {
        case .signup:
            HTTPMethod = "POST"
            path = "/users"
            loadingTitle = "Signing Up"
            successCode = 201
        case .login:
            HTTPMethod = "POST"
            path = "/sessions"
            loadingTitle = "Logging In"
            successCode = 200
        case .email:
            HTTPMethod = "PUT"
            path = "/email"
            loadingTitle = "Changing Email"
            successCode = 200
        }

        func clearCodeInputView(_: UIAlertAction) {
            (view.viewWithTag(17) as! CodeInputView).clear()
        }

        let request = api.request(HTTPMethod, path, ["code": code, "email": email])
        let dataTask = Net.dataTaskWithRequest(request, self, loadingTitle: loadingTitle, successCode: successCode, errorHandler: clearCodeInputView) { JSONObject in
            account.email = self.email

            switch self.method {
            case .Signup, .Login:
                let accessToken = JSONObject!["access_token"]! as! String
                account.setUserWithAccessToken(accessToken, firstName: "", lastName: "")
                account.accessToken = accessToken
            case .Email:
                self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        dataTask.resume()
    }

    // MARK: - Actions

    func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
}

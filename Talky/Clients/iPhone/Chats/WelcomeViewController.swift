import UIKit
import UIButtonBackgroundColor

class WelcomeViewController: UIViewController {
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange

        let logoLabel = UILabel(frame: CGRect(x: 0, y: 44, width: view.frame.width, height: 60))
        logoLabel.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        logoLabel.font = UIFont.boldSystemFont(ofSize: 72)
        logoLabel.text = "Chats"
        logoLabel.textAlignment = .center
        logoLabel.textColor = .white
        view.addSubview(logoLabel)

        let taglineLabel = UILabel(frame: CGRect(x: 0, y: 150, width: view.frame.width, height: 30))
        taglineLabel.autoresizingMask = logoLabel.autoresizingMask
        taglineLabel.font = UIFont.boldSystemFont(ofSize: 24)
        taglineLabel.text = "Chat with Friends"
        taglineLabel.textAlignment = .center
        taglineLabel.textColor = .white
        view.addSubview(taglineLabel)

        let continueAsGuestButton = UIButton(type: .custom)
        continueAsGuestButton.addTarget(account, action: #selector(Account.continueAsGuest), for: .touchUpInside)
        continueAsGuestButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        continueAsGuestButton.frame = CGRect(x: (view.frame.width-184)/2, y: view.frame.height-188, width: 184, height: 44)
        continueAsGuestButton.setTitleColor(.blue, for: UIControlState())
        continueAsGuestButton.setTitleColor(.darkGray, for: .highlighted)
        continueAsGuestButton.setTitle("Continue as Guest", for: UIControlState())
        continueAsGuestButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(continueAsGuestButton)

        let signUpButton = UIButton(type: .custom)
        signUpButton.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        signUpButton.setBackgroundColor(.purpleColor(), forState: .Normal)
        signUpButton.frame = CGRect(x: 0, y: view.frame.height-128, width: view.frame.width, height: 64)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        signUpButton.setTitle("Sign Up", for: UIControlState())
        signUpButton.addTarget(self, action: #selector(WelcomeViewController.signUpLogInAction(_:)), for: .touchUpInside)
        view.addSubview(signUpButton)

        let logInButton = UIButton(type: .custom)
        logInButton.tag = 1
        logInButton.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        logInButton.setBackgroundColor(.blueColor(), forState: .Normal)
        logInButton.frame = CGRect(x: 0, y: view.frame.height-64, width: view.frame.width, height: 64)
        logInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        logInButton.setTitle("Log In", for: UIControlState())
        logInButton.addTarget(self, action: #selector(WelcomeViewController.signUpLogInAction(_:)), for: .touchUpInside)
        view.addSubview(logInButton)
    }

    // MARK: - Actions

    func signUpLogInAction(_ button: UIButton) {
        let tableViewController = button.tag == 0 ? SignUpTableViewController() : LogInTableViewController()
        let navigationController = UINavigationController(rootViewController: tableViewController)
        present(navigationController, animated: true, completion: nil)
    }
}

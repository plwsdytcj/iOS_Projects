import UIKit
import Alerts
import Networking
import TextFieldTableViewCell
import Validator

class LogInTableViewController: UITableViewController, UITextFieldDelegate {
    convenience init() {
        self.init(style: .grouped)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(LogInTableViewController.cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(LogInTableViewController.doneAction))
        title = "Log In"
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
        textField.clearButtonMode = .WhileEditing
        textField.delegate = self
        textField.keyboardType = .EmailAddress
        textField.placeholder = "Email"
        textField.returnKeyType = .Done
        textField.becomeFirstResponder()
        return cell
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneAction()
        return true
    }

    // MARK: - Actions

    func cancelAction() {
        tableView.textFieldForRowAtIndexPath(IndexPath(forRow: 0, inSection: 0))?.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    func doneAction() {
        let email = tableView.textFieldForRowAtIndexPath(IndexPath(forRow: 0, inSection: 0))!.text!.strip()

        // Validate email
        guard email.isValidEmail else {
            return alert(title: "", message: Validator.invalidEmailMessage)
        }

        // Create code with email
        let request = api.request("POST", "/login", ["email": email])
        let dataTask = Net.dataTaskWithRequest(request, self) { _ in
            let enterCodeViewController = EnterCodeViewController(method: .Login, email: email)
            self.navigationController!.pushViewController(enterCodeViewController, animated: true)
        }
        dataTask.resume()
    }
}

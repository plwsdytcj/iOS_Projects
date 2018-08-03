import UIKit

class NewMessageTableViewController: TextViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TokenLabelDelegate, UITextViewDelegate {
    var user: User?
    var toTextField: ToTextField!
    var tokenLabel: TokenLabel!
    var filteredTableView: UITableView!
    var filteredUsers = [User]()

    init(user: User?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(NewMessageTableViewController.resignAction))
        let sendBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(NewMessageTableViewController.sendMessageAction))
        sendBarButtonItem.isEnabled = false
        navigationItem.rightBarButtonItem = sendBarButtonItem
        title = "New Note"
    }

    // MARK: - UIViewController

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 44+8, left: 12, bottom: 25, right: 12)

        toTextField = ToTextField(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 43.5))
        toTextField.addTarget(self, action: #selector(NewMessageTableViewController.textFieldDidChange(_:)), for: .editingChanged)
        toTextField.delegate = self
        view.addSubview(toTextField)

        tokenLabel = TokenLabel(origin: CGPoint(x: 37, y: 8.5))
        tokenLabel.delegate = self
        view.addSubview(tokenLabel)

        let separator = UIView(frame: CGRect(x: 15, y: 43.5, width: view.frame.width-15, height: 0.5))
        separator.autoresizingMask = .flexibleWidth
        separator.backgroundColor = UIColor(white: 199/255.0, alpha: 1)
        view.addSubview(separator)

        filteredTableView = UITableView(frame: .zero, style: .plain)
        filteredTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        filteredTableView.dataSource = self
        filteredTableView.delegate = self
        filteredTableView.isHidden = true
        filteredTableView.keyboardDismissMode = .interactive
        filteredTableView.rowHeight = userTableViewCellHeight
        filteredTableView.scrollsToTop = false
        filteredTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
        view.addSubview(filteredTableView)

        if let user = user {
            tokenLabel.text = user.username
            textView.becomeFirstResponder()
        } else {
            tokenLabel.isHidden = true
            toTextField.becomeFirstResponder()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        filteredTableView.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.height-topLayoutGuide.length-44)
    }

    // MARK: - TextViewController

    override func setTextViewBottomInset(_ insetBottom: CGFloat) {
        super.setTextViewBottomInset(insetBottom)
        filteredTableView.contentInset.bottom = insetBottom
        filteredTableView.scrollIndicatorInsets.bottom = insetBottom
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        let user = filteredUsers[indexPath.row]
        cell.pictureImageView.configureWithUser(user)
        cell.nameLabel.text = user.name
        cell.usernameLabel.text = user.username
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        user = filteredUsers[indexPath.row]
        tokenizeToTextField()
        textView.becomeFirstResponder()
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if tokenLabel.isHidden { return true }
        if !tokenLabel.isFirstResponder {
            tokenLabel.becomeFirstResponder()
        } else {
            alert(title: "", message: "Multiple recipients isn't supported yet.")
        }
        return false
    }

    func textFieldDidChange(_ textField: UITextField!) {
        // Update filteredUsers
        if textField.hasText {
            filteredUsers = account.users.filter() { user in
                return (user.name + " " + user.username).matchesFilterString(textField.text!)
            }
        } else {
            filteredUsers.removeAll()
        }

        // Update filteredTableView
        if filteredUsers.count > 0 {
            textView.contentOffset.y = -topLayoutGuide.length // scrolls to top
            filteredTableView.reloadData()
            setFilteredTableViewHidden(false)
        } else {
            setFilteredTableViewHidden(true)
        }

        updateSendBarButtonItemEnabled()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tokenizeToTextField()
        textView.becomeFirstResponder()
        return false
    }

    // MARK: - TokenLabelDelegate

    func tokenLabel(_ tokenLabel: TokenLabel, didInsertText text: String) {
        if text == "\n" {
            textView.becomeFirstResponder()
            return
        }
        toTextField.text = text
        deleteTokenLabel()
    }

    func tokenLabelDidDeleteBackward(_ tokenLabel: TokenLabel) {
        deleteTokenLabel()
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        updateSendBarButtonItemEnabled()
    }

    // MARK: - Actions

    func resignAction() {
        resignTextInputs()
        dismiss(animated: true, completion: nil)
    }

    func sendMessageAction() {
        guard let user = user else {
            return alert(title: "", message: "No user found with that username.")
        }

        let messageText = textView.text.strip()
        let date = Date()
        let message = Message(incoming: false, text: messageText, sentDate: date)
        var chat: Chat
        if let index = account.chats.index(where: { $0.user === user }) {
            chat = account.chats[index]
            chat.lastMessageText = messageText
            chat.lastMessageSentDate = date
        } else {
            chat = Chat(user: user, lastMessageText: messageText, lastMessageSentDate: date)
            account.chats.insert(chat, at: 0)
        }
        chat.loadedMessages.append([message])

        resignAction()
        NotificationCenter.default.post(name: Notification.Name(rawValue: AccountDidSendMessageNotification), object: chat)
    }

    // MARK: - Helpers

    func resignTextInputs() {
        toTextField.resignFirstResponder()
        textView.resignFirstResponder()
    }

    func setFilteredTableViewHidden(_ hidden: Bool) {
        if filteredTableView.isHidden == hidden { return }
        filteredTableView.isHidden = hidden
        filteredTableView.scrollsToTop = !hidden
        textView.isScrollEnabled = hidden
        textView.scrollsToTop = hidden
    }

    func updateSendBarButtonItemEnabled() {
        let isToTextFieldGood = toTextField.hasText && toTextField.text!.strip() != ""
        let isTokenLabelGood  = tokenLabel.hasText()  &&  tokenLabel.text!.strip() != ""
        let isTextViewGood    = textView.hasText    &&     textView.text.strip() != ""
        navigationItem.rightBarButtonItem!.enabled = (isToTextFieldGood || isTokenLabelGood) && isTextViewGood
    }

    func tokenizeToTextField() {
        if let user = user {
            tokenLabel.text = user.username
            tokenLabel.isHidden = false
        } else {
            if let toTextFieldText = toTextField.text {
                let strippedText = toTextFieldText.strip()
                if strippedText != "" {
                    tokenLabel.text = strippedText
                    tokenLabel.isHidden = false
                }
            }
        }
        setFilteredTableViewHidden(true)
        toTextField.text = ""
    }

    func deleteTokenLabel() {
        user = nil
        tokenLabel.isHidden = true
        tokenLabel.text = nil
        updateSendBarButtonItemEnabled()
        toTextField.becomeFirstResponder()
    }
}

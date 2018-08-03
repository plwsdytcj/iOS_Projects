import UIKit

class ChatsTableViewController: UITableViewController {
    var chats: [Chat] { return account.chats }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    convenience init() {
        self.init(style: .plain)
        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(ChatsTableViewController.newMessageAction))
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem // TODO: KVO
        tableView.backgroundColor = .white
        tableView.rowHeight = chatTableViewCellHeight
        tableView.separatorInset.left = chatTableViewCellInsetLeft
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatCell")
        NotificationCenter.default.addObserver(self, selector: #selector(ChatsTableViewController.accountDidSendMessage(_:)), name: NSNotification.Name(rawValue: AccountDidSendMessageNotification), object: nil)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
        cell.configureWithChat(chats[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            account.chats.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if chats.count == 0 {
                navigationItem.leftBarButtonItem = nil  // TODO: KVO
            }
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
        let chatViewController = ChatViewController(chat: chat)
        navigationController!.pushViewController(chatViewController, animated: true)
    }

    // MARK: - Actions

    func newMessageAction() {
        let navigationController = UINavigationController(rootViewController: NewMessageTableViewController(user: nil))
        present(navigationController, animated: true, completion: nil)
    }

    // MARK: - AccountDidSendMessageNotification

    // Move the note I just commented on to the top
    func accountDidSendMessage(_ notification: Notification) {
        let indexPath0 = IndexPath(row: 0, section: 0)

        let chat = notification.object as! Chat
        let row = chats.index { $0 === chat }!
        if row == 0 {
            if chats.count > tableView.numberOfRows(inSection: 0) {
                return tableView.insertRows(at: [indexPath0], with: .none)
            }
        } else {
            account.chats.remove(at: row)
            account.chats.insert(chat, at: 0)
            let fromIndexPath = IndexPath(row: row, section: 0)
            tableView.moveRow(at: fromIndexPath, to: indexPath0)
        }

        tableView.reloadRows(at: [indexPath0], with: .none)
    }
}

import UIKit

class SettingsTableViewController: UITableViewController {
    enum Section : Int {
        case email
        case logOut
        case deleteAccount
    }

    convenience init() {
        self.init(style: .grouped)
        title = "Settings"
    }

    deinit {
        if isViewLoaded {
            account.removeObserver(self, forKeyPath: "email")
        }
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        account.addObserver(self, forKeyPath: "email", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Set style & identifier based on section
        let section = Section(rawValue: indexPath.section)!
        var style: UITableViewCellStyle = .default
        var cellIdentifier = "DefaultCell"
        if section == .email {
            style = .value1
            cellIdentifier = "Value1Cell"
        }

        // Dequeue or create cell with style & identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: style, reuseIdentifier: cellIdentifier)
            cell?.textLabel!.font = UIFont.systemFont(ofSize: 18)
        }

        // Customize cell
        cell?.textLabel!.textAlignment = .center
        switch section {
        case .email:
            cell?.accessoryType = .disclosureIndicator
            cell?.detailTextLabel!.text = account.email
            cell?.textLabel!.text = "Email"
            cell?.textLabel!.textAlignment = .left
        case .logOut:
            cell?.textLabel!.text = "Log Out"
            cell?.textLabel!.textColor = UIColor(red: 0/255, green: 88/255, blue: 249/255, alpha: 1)
        case .deleteAccount:
            cell?.textLabel!.text = "Delete Account"
            cell?.textLabel!.textColor = UIColor(red: 252/255, green: 53/255, blue: 56/255, alpha: 1)
        }

        return cell!
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section)! {
        case .email:
            navigationController!.pushViewController(EditEmailTableViewController(), animated: true)
        case .logOut:
            if account.accessToken == "guest_access_token" {
                account.logOutGuest()
            } else {
                account.logOut(self)
            }
        case .deleteAccount:
            let actionSheet = UIAlertController(title: "Deleting your account will permanently delete your first & last name, email address, and chat history.\n\nAre you sure you want to delete your account?", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Delete Account", style: .destructive) { _ in
                if account.accessToken == "guest_access_token" {
                    return account.logOutGuest()
                }
                account.deleteAccount(self)
            })
            present(actionSheet, animated: true, completion: nil)
        }
    }

    // MARK: - NSKeyValueObserving

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Update email cell when account.email changes
        let emailIndexPath = IndexPath(row: 0, section: Section.email.rawValue)
        let emailCell = tableView.cellForRow(at: emailIndexPath)
        emailCell?.detailTextLabel!.text = account.email
    }
}

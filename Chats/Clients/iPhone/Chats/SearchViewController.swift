import UIKit

class SearchViewController: UIViewController {
    var searchController: UISearchController!

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        title = "Search"
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let noticeLabel = UILabel(frame: CGRect.zero)
        noticeLabel.numberOfLines = 2
        noticeLabel.text = "Search for users by name or username."
        noticeLabel.textAlignment = .center
        view.addSubview(noticeLabel)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: noticeLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: noticeLabel, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 60),
            NSLayoutConstraint(item: noticeLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
        ])

        let searchResultsTableViewController = SearchResultsTableViewController(style: .plain)
        searchController = UISearchController(searchResultsController: searchResultsTableViewController)
        searchController.searchResultsUpdater = searchResultsTableViewController

        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .minimal

        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false

        definesPresentationContext = true
    }
}

class SearchResultsTableViewController: UITableViewController, UISearchResultsUpdating {
    var visibleResults = account.users

    /// A `nil` / empty filter string means show all results. Otherwise, show only results containing the filter.
    var filterString: String? = nil {
        didSet {
            if filterString == nil || filterString!.isEmpty {
                visibleResults.removeAll()
            } else {
                visibleResults = account.users.filter() { user in
                    return (user.name + " " + user.username).matchesFilterString(filterString!)
                }
            }
            tableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            cell?.textLabel!.font = UIFont.systemFont(ofSize: 18)
        }

        let user = visibleResults[indexPath.row]
        let imageView = cell?.imageView!
        if let pictureName = user.pictureName() {
            imageView?.image = UIImage(named: pictureName)
            // imageView.layer.cornerRadius = imageView.frame.width / 2
            // imageView.layer.masksToBounds = true
        } else {
            imageView?.image = nil
        }
        cell?.textLabel!.text = user.name
        cell?.detailTextLabel!.text = user.username

        return cell!
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = visibleResults[indexPath.row]
        presentingViewController!.navigationController!.pushViewController(ProfileTableViewController(user: user), animated: true)
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else { return }
        filterString = searchController.searchBar.text
    }
}

extension String {
    func words() -> Array<String> {
        var words = [String]()
        let nonAlphanumericCharacterSet = CharacterSet.alphanumerics.inverted
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = nonAlphanumericCharacterSet
        var result: NSString?
        while scanner.scanUpToCharacters(from: nonAlphanumericCharacterSet, into: &result) {
            words.append(result as! String)
        }
        return words
        // // The following implementation is twice as slow than the one above.
        // return componentsSeparatedByCharactersInSet(nonAlphanumericCharacterSet).filter { $0 != "" }
    }

    //  http://stackoverflow.com/a/29006884/242933
    // let filterPredicate = NSPredicate(format: "self contains[c] %@", argumentArray: [filterString!])
    // visibleResults = account.users.filter { filterPredicate.evaluateWithObject($0) }
    func matchesFilterString(_ filterString: String) -> Bool {
        for filterWord in filterString.words() {
            func wordsHasMatch() -> Bool {
                for word in words() {
                    if word.hasCDWPrefix(filterWord) {
                        return true
                    }
                }
                return false
            }
            if !wordsHasMatch() { return false }
        }
        return true
    }

    func hasCDWPrefix(_ prefix: String) -> Bool {
        let options: NSString.CompareOptions = [.anchored, .caseInsensitive, .diacriticInsensitive, .widthInsensitive]
        return range(of: prefix, options: options) != nil
    }
}

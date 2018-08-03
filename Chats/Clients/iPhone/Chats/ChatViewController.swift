import AudioToolbox
import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    static let chatMessageFontSize: CGFloat = 17
    fileprivate static let toolBarMinHeight: CGFloat = 44
    fileprivate static let textViewMaxHeight: (portrait: CGFloat, landscape: CGFloat) = (portrait: 272, landscape: 90)
    fileprivate static let messageSoundOutgoing: SystemSoundID = {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "MessageOutgoing" as CFString, "aiff" as CFString, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }()

    let chat: Chat
    var tableView: UITableView!
    var toolBar: UIToolbar!
    var textView: UITextView!
    var sendButton: UIButton!
    var rotating = false

    override var inputAccessoryView: UIView! {
        get {
            if toolBar == nil {
                toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: ChatViewController.toolBarMinHeight-0.5))

                textView = InputTextView(frame: CGRect.zero)
                textView.backgroundColor = UIColor(white: 250/255, alpha: 1)
                textView.delegate = self
                textView.font = UIFont.systemFont(ofSize: ChatViewController.chatMessageFontSize)
                textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).cgColor
                textView.layer.borderWidth = 0.5
                textView.layer.cornerRadius = 5
                //            textView.placeholder = "Message"
                textView.scrollsToTop = false
                textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
                toolBar.addSubview(textView)

                sendButton = UIButton(type: .system)
                sendButton.isEnabled = false
                sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
                sendButton.setTitle("Send", for: UIControlState())
                sendButton.setTitleColor(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1), for: .disabled)
                sendButton.setTitleColor(UIColor(red: 1/255, green: 122/255, blue: 255/255, alpha: 1), for: UIControlState())
                sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
                sendButton.addTarget(self, action: #selector(ChatViewController.sendMessageAction), for: UIControlEvents.touchUpInside)
                toolBar.addSubview(sendButton)

                // Auto Layout allows `sendButton` to change width, e.g., for localization.
                textView.translatesAutoresizingMaskIntoConstraints = false
                sendButton.translatesAutoresizingMaskIntoConstraints = false
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: toolBar, attribute: .left, multiplier: 1, constant: 8))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: toolBar, attribute: .top, multiplier: 1, constant: 7.5))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .right, relatedBy: .equal, toItem: sendButton, attribute: .left, multiplier: 1, constant: -2))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: toolBar, attribute: .bottom, multiplier: 1, constant: -8))
                toolBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .right, relatedBy: .equal, toItem: toolBar, attribute: .right, multiplier: 1, constant: 0))
                toolBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: toolBar, attribute: .bottom, multiplier: 1, constant: -4.5))
            }
            return toolBar
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        title = chat.user.name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder : Bool {
        return true
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // smooths push animation

        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: ChatViewController.toolBarMinHeight, right: 0)
        tableView.contentInset = edgeInsets
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .none
        tableView.register(MessageSentDateTableViewCell.self, forCellReuseIdentifier: "SentDateCell")
        view.addSubview(tableView)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatViewController.menuControllerWillHide(_:)), name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil) // #CopyMessage

        // tableViewScrollToBottomAnimated(false) // doesn't work
    }

    override func viewDidAppear(_ animated: Bool)  {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    override func viewWillDisappear(_ animated: Bool)  {
        super.viewWillDisappear(animated)
        chat.draft = textView.text
    }

    // This gets called a lot. Perhaps there's a better way to know when `view.window` has been set?
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()

        if !chat.draft.isEmpty {
            textView.text = chat.draft
            chat.draft = ""
            textViewDidChange(textView)
            textView.becomeFirstResponder()
        }
    }

//    // #iOS7.1
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willAnimateRotation(to: toInterfaceOrientation, duration: duration)

        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) {
            if toolBar.frame.height > ChatViewController.textViewMaxHeight.landscape {
                toolBar.frame.size.height = ChatViewController.textViewMaxHeight.landscape+8*2-0.5
            }
        } else { // portrait
            updateTextViewHeight()
        }
    }
//    // #iOS8
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return chat.loadedMessages.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.loadedMessages[section].count + 1 // for sent-date cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SentDateCell", for: indexPath) as! MessageSentDateTableViewCell
            let message = chat.loadedMessages[indexPath.section][0]
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            cell.sentDateLabel.text = dateFormatter.string(from: message.sentDate)
            return cell
        } else {
            let cellIdentifier = "BubbleCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MessageBubbleTableViewCell!
            if cell == nil {
                cell = MessageBubbleTableViewCell(style: .default, reuseIdentifier: cellIdentifier)

                // Add gesture recognizers #CopyMessage
                let action: Selector = #selector(ChatViewController.messageShowMenuAction(_:))
                let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)
                doubleTapGestureRecognizer.numberOfTapsRequired = 2
                cell?.bubbleImageView.addGestureRecognizer(doubleTapGestureRecognizer)
                cell?.bubbleImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: action))
            }
            let message = chat.loadedMessages[indexPath.section][indexPath.row-1]
            cell?.configureWithMessage(message)
            return cell!
        }
    }

    // MARK: - UITableViewDelegate

    // Reserve row selection #CopyMessage
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    func tableViewScrollToBottomAnimated(_ animated: Bool) {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            tableView.scrollToRow(at: IndexPath(row: numberOfRows-1, section: 0), at: .bottom, animated: animated)
        }
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
        sendButton.isEnabled = textView.hasText
    }

    func updateTextViewHeight() {
        let oldHeight = textView.frame.height
        let maxHeight = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? ChatViewController.textViewMaxHeight.portrait : ChatViewController.textViewMaxHeight.landscape
        var newHeight = min(textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height, maxHeight)
        #if arch(x86_64) || arch(arm64)
            newHeight = ceil(newHeight)
        #else
            newHeight = CGFloat(ceilf(newHeight.native))
        #endif
        if newHeight != oldHeight {
            toolBar.frame.size.height = newHeight+8*2-0.5
        }
    }

    // MARK: - UIKeyboard Notifications

    func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let insetNewBottom = tableView.convert(frameNew, from: nil).height
        let insetOld = tableView.contentInset
        let insetChange = insetNewBottom - insetOld.bottom
        let overflow = tableView.contentSize.height - (tableView.frame.height-insetOld.top-insetOld.bottom)

        let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations: (() -> Void) = {
            if !(self.tableView.isTracking || self.tableView.isDecelerating) {
                // Move content with keyboard
                if overflow > 0 {                   // scrollable before
                    self.tableView.contentOffset.y += insetChange
                    if self.tableView.contentOffset.y < -insetOld.top {
                        self.tableView.contentOffset.y = -insetOld.top
                    }
                } else if insetChange > -overflow { // scrollable after
                    self.tableView.contentOffset.y += insetChange + overflow
                }
            }
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16)) // http://stackoverflow.com/a/18873820/242933
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    func keyboardDidShow(_ notification: Notification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let insetNewBottom = tableView.convert(frameNew, from: nil).height

        // Inset `tableView` with keyboard
        let contentOffsetY = tableView.contentOffset.y
        tableView.contentInset.bottom = insetNewBottom
        tableView.scrollIndicatorInsets.bottom = insetNewBottom
        // Prevents jump after keyboard dismissal
        if self.tableView.isTracking || self.tableView.isDecelerating {
            tableView.contentOffset.y = contentOffsetY
        }
    }

    // MARK: - Actions

    func sendMessageAction() {
        // Autocomplete text before sending #hack
        textView.resignFirstResponder()
        textView.becomeFirstResponder()

        
        let messageText = textView.text.strip()
        let date = Date()
        chat.loadedMessages.append([Message(incoming: false, text: messageText, sentDate: date)])
        chat.lastMessageText = messageText
        chat.lastMessageSentDate = date
        NotificationCenter.default.post(name: Notification.Name(rawValue: AccountDidSendMessageNotification), object: chat)

        textView.text = nil
        updateTextViewHeight()
        sendButton.isEnabled = false

        let lastSection = tableView.numberOfSections
        tableView.beginUpdates()
        tableView.insertSections(IndexSet(integer: lastSection), with: .automatic)
        tableView.insertRows(at: [
            IndexPath(row: 0, section: lastSection),
            IndexPath(row: 1, section: lastSection)
            ], with: .automatic)
        tableView.endUpdates()
        tableViewScrollToBottomAnimated(true)
        AudioServicesPlaySystemSound(ChatViewController.messageSoundOutgoing)
    }

    // Handle actions #CopyMessage
    // 1. Select row and show "Copy" menu
    func messageShowMenuAction(_ gestureRecognizer: UITapGestureRecognizer) {
        let twoTaps = (gestureRecognizer.numberOfTapsRequired == 2)
        let doubleTap = (twoTaps && gestureRecognizer.state == .ended)
        let longPress = (!twoTaps && gestureRecognizer.state == .began)
        if doubleTap || longPress {
            let pressedIndexPath = tableView.indexPathForRow(at: gestureRecognizer.location(in: tableView))!
            tableView.selectRow(at: pressedIndexPath, animated: false, scrollPosition: .none)

            let menuController = UIMenuController.shared
            let bubbleImageView = gestureRecognizer.view!
            menuController.setTargetRect(bubbleImageView.frame, in: bubbleImageView.superview!)
            menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(ChatViewController.messageCopyTextAction(_:)))]
            menuController.setMenuVisible(true, animated: true)
        }
    }
    // 2. Copy text to pasteboard
    func messageCopyTextAction(_ menuController: UIMenuController) {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        let selectedMessage = chat.loadedMessages[selectedIndexPath!.section][selectedIndexPath!.row-1]
        UIPasteboard.general.string = selectedMessage.text
    }
    // 3. Deselect row
    func menuControllerWillHide(_ notification: Notification) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        (notification.object as! UIMenuController).menuItems = nil
    }
}

class InputTextView: UITextView {
    // Only show "Copy" when selecting a row while `textView` is first responder #CopyMessage
    override func canPerformAction(_ action: Selector, withSender sender: Any!) -> Bool {
        if (delegate as! ChatViewController).tableView.indexPathForSelectedRow != nil {
            return action == #selector(ChatViewController.messageCopyTextAction(_:))
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    // More specific than implementing `nextResponder` to return `delegate`, which might cause side effects?
    func messageCopyTextAction(_ menuController: UIMenuController) {
        (delegate as! ChatViewController).messageCopyTextAction(menuController)
    }
}

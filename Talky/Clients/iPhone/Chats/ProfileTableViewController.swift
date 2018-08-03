import MobileCoreServices
import UIKit
import Alerts
import TextFieldTableViewCell
import Validator

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let isMyProfile: Bool
    var saveChanges = false
    let user: User

    weak var patchMeDataTask: URLSessionDataTask?

    init(user: User) {
        isMyProfile = (user.ID == account.user.ID)
        self.user = user
        super.init(style: .plain)
        title = "Profile"

        if isMyProfile {
            navigationItem.rightBarButtonItem = editButtonItem
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(ProfileTableViewController.chatAction))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if isMyProfile && isViewLoaded {
            user.removeObserver(self, forKeyPath: "firstName")
            user.removeObserver(self, forKeyPath: "lastName")
        }
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        tableView.separatorInset.left = 12 + 60 + 12 + 22
        tableView.tableFooterView = UIView(frame: CGRect.zero) // hides trailing separators

        addPictureAndName()

        if isMyProfile {
            user.addObserver(self, forKeyPath: "firstName", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
            user.addObserver(self, forKeyPath: "lastName", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
            saveChanges = true

            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ProfileTableViewController.cancelEditingAction))
            tableView.setEditing(false, animated: false)
            tableView.tableHeaderView = nil
            tableView.viewWithTag(3)?.removeFromSuperview()

            let pictureButton = UIButton(type: .system)
            pictureButton.addTarget(self, action: #selector(ProfileTableViewController.editPictureAction), for: .touchUpInside)
            pictureButton.adjustsImageWhenHighlighted = false
            pictureButton.clipsToBounds = true
            pictureButton.frame = CGRect(x: 15, y: 12, width: 60, height: 60)
            pictureButton.layer.borderColor = UIColor(white: 200/255, alpha: 1).cgColor
            pictureButton.layer.borderWidth = 1
            pictureButton.layer.cornerRadius = 60/2
            if let pictureName = user.pictureName() {
                pictureButton.setBackgroundImage(UIImage(named: pictureName), for: UIControlState())
            } else {
                pictureButton.setTitle("add photo", for: UIControlState())
            }
            pictureButton.tag = 4
            pictureButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            pictureButton.titleLabel?.numberOfLines = 0
            pictureButton.titleLabel?.textAlignment = .center
            tableView.addSubview(pictureButton)

            if user.pictureName() != nil {
                addEditPictureButton()
            }
        } else {
            navigationItem.leftBarButtonItem = nil
            tableView.viewWithTag(4)!.removeFromSuperview()
            tableView.viewWithTag(5)?.removeFromSuperview()
            addPictureAndName()

            if saveChanges {
                let firstNameTextField = tableView.textFieldForRowAtIndexPath(IndexPath(forRow: 0, inSection: 0))!
                let lastNameTextField = tableView.textFieldForRowAtIndexPath(IndexPath(forRow: 1, inSection: 0))!

                func stripTextField(_ textField: UITextField) -> String {
                    return textField.hasText ? textField.text!.strip() : ""
                }
                let firstName = stripTextField(firstNameTextField)
                let lastName = stripTextField(lastNameTextField)

                func alertError(_ message: String) {
                    alert(title: "", message: message)
                    setEditing(true, animated: false)
                }
                guard firstName.isValidName else {
                    alertError(Validator.invalidFirstNameMessage)
                    return tableView.reloadData()
                }
                guard lastName.isValidName else {
                    alertError(Validator.invalidLastNameMessage)
                    return tableView.reloadData()
                }

                if account.accessToken == "guest_access_token" {
                    (user as! ServerUser).serverFirstName = firstName
                    (user as! ServerUser).serverLastName = lastName
                    return tableView.reloadData()
                }

                if let patchMeDataTask = patchMeDataTask {
                    patchMeDataTask.cancel()
                }
                patchMeDataTask = account.patchMe(self, firstName: firstName, lastName: lastName)
            }
        }
        tableView.reloadData()
    }

    func addEditPictureButton() {
        let editPictureButton = UIButton(type: .system)
        editPictureButton.frame = CGRect(x: 28, y: 12+60-0.5, width: 34, height: 21)
        editPictureButton.setTitle("edit", for: UIControlState())
        editPictureButton.tag = 5
        editPictureButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        editPictureButton.isUserInteractionEnabled = false
        tableView.addSubview(editPictureButton)
    }

    func addPictureAndName() {
        let userPictureImageView = UserPictureImageView(frame: CGRect(x: 15, y: 12, width: 60, height: 60))
        userPictureImageView.configureWithUser(user)
        userPictureImageView.tag = 3
        tableView.addSubview(userPictureImageView)

        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 12+60+12))
        tableHeaderView.autoresizingMask = .flexibleWidth
        tableHeaderView.isUserInteractionEnabled = false
        tableView.tableHeaderView = tableHeaderView

        let nameLabel = UILabel(frame: CGRect(x: 91, y: 31, width: tableHeaderView.frame.width-91, height: 21))
        nameLabel.autoresizingMask = .flexibleWidth
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        nameLabel.tag = 18
        nameLabel.text = user.name
        tableHeaderView.addSubview(nameLabel)
    }

    // MARK: - NSKeyValueObserving

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        (tableView.viewWithTag(18) as! UILabel?)?.text = user.name
    }

    // MARK: - Actions

    func chatAction() {
        let chat = Chat(user: user, lastMessageText: "", lastMessageSentDate: Date()) // TODO: Pass nil for text & date
        navigationController!.pushViewController(ChatViewController(chat: chat), animated: true)
    }

    func editPictureAction() {
        func actionSheetHandler(_ sourceType: UIImagePickerControllerSourceType) {
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                imagePickerController.sourceType = sourceType
                present(imagePickerController, animated: true, completion: nil)
            } else {
                let sourceString = sourceType == .camera ? "Camera" : "Photo Library"
                alert(title: "\(sourceString) Unavailable", message: nil)
            }
        }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            actionSheetHandler(.camera)
        })
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default) { _ in
            actionSheetHandler(.photoLibrary)
        })
        if user.pictureName() != nil {
            actionSheet.addAction(UIAlertAction(title: "Delete Photo", style: .destructive) { _ in
                let pictureButton = self.tableView.viewWithTag(4) as! UIButton
                pictureButton.setBackgroundImage(nil, for: UIControlState())
                pictureButton.setTitle("add photo", for: UIControlState())
                self.tableView.viewWithTag(5)?.removeFromSuperview()
            })
        }
        present(actionSheet, animated: true, completion: nil)
    }

    func cancelEditingAction() {
        saveChanges = false
        setEditing(false, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEditing ? 2 : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
        cell.textFieldLeftLayoutConstraint.constant = tableView.separatorInset.left + 1
        let textField = cell.textField
        textField.clearButtonMode = .WhileEditing

        var placeholder: String!
        if indexPath.row == 0 {
            placeholder = "First Name"
            textField.text = user.firstName
        } else {
            placeholder = "Last Name"
            textField.text = user.lastName
        }
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor(white: 127/255, alpha: 1)])
        return cell
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString!
        if UTTypeConformsTo(mediaType!, kUTTypeImage) {
            var image = info[UIImagePickerControllerEditedImage] as! UIImage!
            if image == nil {
                image = info[UIImagePickerControllerOriginalImage] as! UIImage!
            }

//            let cropRect = (info[UIImagePickerControllerCropRect] as! NSValue).CGRectValue()
//            print(cropRect)

            // Resize image to 2048px max width
            image = image?.resizedImage(2048)

            // TEST: Save image to documents directory.

            var uuid = UUID().uuidString // E621E1F8-C36C-495A-93FC-0C247A3E6E5F
            let range = uuid.startIndex..<uuid.characters.index(uuid.endIndex, offsetBy: -12)
            uuid = uuid.stringByReplacingOccurrencesOfString("-", withString: "", options: .LiteralSearch, range: range).lowercased()
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(uuid).jpg")
//            let imageData = UIImageJPEGRepresentation(image, 0.9)
//            imageData.writeToFile(fileURL, atomically: true)
            print(fileURL)

            // Upload image to server

            let pictureButton = tableView.viewWithTag(4) as! UIButton
            pictureButton.setBackgroundImage(image, for: UIControlState())
            if pictureButton.title(for: UIControlState()) != nil {
                pictureButton.setTitle(nil, for: UIControlState())
                addEditPictureButton()
            }

            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension UIImage {
    func resizedImage(_ max: CGFloat) -> UIImage {
        let width = size.width
        let height = size.height

        let scale = width > height ? max/width : max/height
        if scale >= 1 {
            return self
        } else {
            let newWidth = width * scale
            let newHeight = height * scale

            UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0)
            draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage!
        }
    }
}

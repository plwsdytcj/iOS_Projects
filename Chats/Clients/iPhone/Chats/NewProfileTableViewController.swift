import MobileCoreServices
import UIKit
import TextFieldTableViewCell

class NewProfileTableViewController: UITableViewController, UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    let email: String
    let key: String

    var pictureImage: UIImage?
    var firstName = ""
    var lastName = ""
    var phone = ""
    var confirmedEmail = ""

    private static var tableViewSeparatorInsetLeftDefault: CGFloat = 15

    init(email: String, key: String) {
        self.email = email
        self.key = key
        super.init(style: .Plain)
        title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneAction")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let pictureButton = UIButton(type: .System)
        pictureButton.addTarget(self, action: "editPictureAction", forControlEvents: .TouchUpInside)
        pictureButton.adjustsImageWhenHighlighted = false
        pictureButton.clipsToBounds = true
        pictureButton.frame = CGRect(x: 15, y: 12, width: 60, height: 60)
        pictureButton.layer.borderColor = UIColor(white: 200/255, alpha: 1).CGColor
        pictureButton.layer.borderWidth = 1
        pictureButton.layer.cornerRadius = 60/2
        pictureButton.setTitle("add photo", forState: .Normal)
        pictureButton.tag = 9
        pictureButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        pictureButton.titleLabel?.numberOfLines = 0
        pictureButton.titleLabel?.textAlignment = .Center
        tableView.addSubview(pictureButton)

        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        NewProfileTableViewController.tableViewSeparatorInsetLeftDefault = tableView.separatorInset.left
        tableView.separatorStyle = .None
        tableView.tableFooterView = UIView(frame: CGRectZero) // hides trailing separators
    }

    // REFACTOR: Could this be made the pictureButton.titleLabel?
    func addEditPictureButton() {
        let editPictureButton = UIButton(type: .System)
        editPictureButton.frame = CGRect(x: 28, y: 12+60-0.5, width: 34, height: 21)
        editPictureButton.setTitle("edit", forState: .Normal)
        editPictureButton.tag = 3
        editPictureButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        editPictureButton.userInteractionEnabled = false
        tableView.addSubview(editPictureButton)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        textField.autocorrectionType = .No
        textField.clearButtonMode = .WhileEditing
        textField.delegate = self
        textField.enablesReturnKeyAutomatically = true
        textField.spellCheckingType = .No

        var placeholder: String!
        var cellSeparatorInsetLeft: CGFloat
        if indexPath.section == 0 {
            cellSeparatorInsetLeft = 12 + 60 + 12 + 22
            cell.textFieldLeftLayoutConstraint.constant = cellSeparatorInsetLeft + 1
            textField.autocapitalizationType = .Words
            textField.keyboardType = UIKeyboardType.Default
            textField.returnKeyType = .Next
            if indexPath.row == 0 {
                placeholder = "First Name"
                textField.tag = 10
                textField.text = firstName
            } else {
                placeholder = "Last Name"
                textField.tag = 11
                textField.text = lastName
            }
        } else { // section == 1
            cellSeparatorInsetLeft = NewProfileTableViewController.tableViewSeparatorInsetLeftDefault
            cell.textFieldLeftLayoutConstraint.constant = cellSeparatorInsetLeft + 1
            placeholder = "Email"
            textField.autocapitalizationType = .None
            textField.keyboardType = UIKeyboardType.EmailAddress
            textField.returnKeyType = .Done
            textField.tag = 12
            textField.text = email
        }
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor(white: 127/255, alpha: 1)])

        // Add cell separator
        if cell.viewWithTag(53) == nil {
            let separatorView = UIView(frame: CGRect(x: cellSeparatorInsetLeft, y: cell.frame.height-0.5, width: cell.frame.width-cellSeparatorInsetLeft, height: 0.5))
            separatorView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
            separatorView.backgroundColor = tableView.separatorColor
            separatorView.tag = 53
            cell.addSubview(separatorView)
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? UITableViewAutomaticDimension : 24
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else { // section == 1
            let view = UIView(frame: CGRectZero)
            view.backgroundColor = .whiteColor()
            return view
        }
    }

    // MARK: - Actions

    func editPictureAction() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take Photo", "Choose Photo")
        if pictureImage != nil {
            // actionSheet.addButtonWithTitle("Edit Photo")
            actionSheet.addButtonWithTitle("Delete Photo")
            actionSheet.destructiveButtonIndex = 3
        }
        actionSheet.showInView(tableView.window!)
    }

    func doneAction() {
        firstName = firstName.strippedString()
        lastName = lastName.strippedString()
        phone = phone.strippedString()

        if let alertView = nameInvalidAlertView() {
            alertView.show()
        } else if let alertView = emailInvalidAlertView() {
            alertView.show()
        } else if let alertView = confirmEmailAlertView() {
            alertView.show()
        } else {
            checkPictureThenCreateUser()
        }
    }

    func nameInvalidAlertView() -> UIAlertView? {
        var nameType: String?
        if !((1...50) ~= firstName.characters.count) {
            nameType = "First"
        } else if !((1...50) ~= lastName.characters.count) {
            nameType = "Last"
        }

        if let messagePrefix = nameType {
            return UIAlertView(title: "", message: "\(messagePrefix) name must be between 1 & 50 characters.", delegate: nil, cancelButtonTitle: "OK")
        } else {
            return nil
        }
    }

    func emailInvalidAlertView() -> UIAlertView? {
        if !((3...254) ~= phone.characters.count && phone.characters.indexOf("@") != nil) {
            return UIAlertView(title: "", message: "Email must be between 3 & 254 characters and have an at sign.", delegate: nil, cancelButtonTitle: "OK")
        } else {
            return nil
        }
    }

    func confirmEmailAlertView() -> UIAlertView? {
        if confirmedEmail != phone {
            let alertView = UIAlertView(title: "Is your email correct?", message: phone, delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
            alertView.tag = 3
            return alertView
        } else {
            return nil
        }
    }

    func checkPictureThenCreateUser() {
        if let alertView = noPictureAlertView() {
            alertView.show()
        } else {
            createProfile()
        }
    }

    func noPictureAlertView() -> UIAlertView? {
        if pictureImage == nil {
            return UIAlertView(title: "", message: "You didn't set a profile picture. Do you want to set one now?", delegate: self, cancelButtonTitle: "Skip", otherButtonTitles: "Set Picture")
        } else {
            return nil
        }
    }

    // 1. Set up Amazon
    // 2. Rewrite & Add Lambda script
    // 3. Add the iPhone upload UI
    // 4. Add iPhone download UI
    func createProfile() {
        let loadingViewController = LoadingViewController(title: "Signing Up")
        presentViewController(loadingViewController, animated: true, completion: nil)

        var fields = ["phone": email, "key": key, "first_name": firstName.stringByAddingFormURLEncoding(), "last_name": lastName.stringByAddingFormURLEncoding(), "email": phone.stringByAddingFormURLEncoding()]
        if pictureImage != nil {
            fields["picture_id"] = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "").lowercaseString
        }
        let request = api.formRequest("POST", "/users", fields)
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if response != nil {
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                let dictionary = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))) as! Dictionary<String, AnyObject>?

                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)

                    if statusCode == 201 {
                        let accessToken = dictionary!["access_token"] as! String!
                        account.setUserWithAccessToken(accessToken, firstName: self.firstName, lastName: self.lastName)
                        account.phone = self.email
                        account.email = self.phone
                        account.accessToken = accessToken

                        if let fields = dictionary!["fields"] as? Dictionary<String, String> {
                            let boundary = Net.multipartBoundary()
                            let request = Net.multipartRequest("POST", NSURL(string: "https://acani-chats.s3.amazonaws.com")!, boundary)
                            let data = Net.multipartData(boundary, fields, UIImageJPEGRepresentation(self.pictureImage!, 0.9)!)
                            let dataTask = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data) { data, response, error in
                                if response != nil {
                                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                                    let responseBody = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                } else {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        UIAlertView(dictionary: nil, error: error, delegate: nil).show()
                                    }
                                }
                            }
                            dataTask.resume()
                        }
                    } else {
                        UIAlertView(dictionary: dictionary as! Dictionary<String, String>?, error: error, delegate: nil).show()
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    UIAlertView(dictionary: nil, error: error, delegate: nil).show()
                }
            }
        }
        dataTask.resume()
    }

    // MARK: - UIAlertViewDelegate

    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView.tag == 3 { // email
            if buttonIndex == alertView.cancelButtonIndex {
                confirmedEmail = ""
            } else {
                confirmedEmail = phone
                checkPictureThenCreateUser()
            }
        } else {               // picture
            if buttonIndex == alertView.cancelButtonIndex {
                createProfile()
            } else {
                editPictureAction()
            }
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidChange(textField: UITextField) {
        switch textField.tag {
        case 10:
            firstName = textField.text!
        case 11:
            lastName = textField.text!
        case 12:
            phone = textField.text!
        default:
            break
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 10 {
            tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.becomeFirstResponder()
        } else if textField.tag == 11 {
            tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))?.becomeFirstResponder()
        } else {
            doneAction()
        }
        return true
    }

    // MARK: - UIActionSheetDelegate

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1, 2: // Camera, Photo
            let sourceType: UIImagePickerControllerSourceType = buttonIndex == 1 ? .Camera : .PhotoLibrary
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                imagePickerController.sourceType = sourceType
                presentViewController(imagePickerController, animated: true, completion: nil)
            } else {
                let sourceString = sourceType == .Camera ? "Camera" : "Photo Library"
                let alertView = UIAlertView(title: "\(sourceString) Unavailable", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
        case 3: // Delete
            pictureImage = nil

            let pictureButton = tableView.viewWithTag(9) as! UIButton
            pictureButton.setBackgroundImage(nil, forState: .Normal)
            pictureButton.setTitle("add photo", forState: .Normal)
            tableView.viewWithTag(3)?.removeFromSuperview()
        default: // Cancel
            break
        }
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString!
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if image.size != CGSizeZero {
                // Crop original image
                if let rect = info[UIImagePickerControllerCropRect]?.CGRectValue {
                    image = UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, rect)!)
                }

                // Limit image dimensions
                pictureImage = image.resizedImage(2048)

                // Update pictureButton
                let pictureButton = tableView.viewWithTag(9) as! UIButton
                pictureButton.setBackgroundImage(pictureImage, forState: .Normal)
                pictureButton.setTitle(nil, forState: .Normal)
                addEditPictureButton()
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension String {
    func strippedString() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

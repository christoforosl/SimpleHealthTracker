// ProfileViewController.swift
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Lock
import AFNetworking
import CoreGraphics
import Auth0


class ProfileViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!

    weak var currentField: UITextField?
    var keyboardFrame: CGRect?
    var profile: Profile!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.avatar.layer.cornerRadius = 50
        self.avatar.layer.masksToBounds = true

        updateUI()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.keyboardFrame = self.view.convert(self.keyboardFrame!, from: nil)
        self.containerHeight.constant = 600 + self.keyboardFrame!.size.height
        if let field = self.currentField {
            self.scrollToField(field: field, keyboardFrame: self.keyboardFrame!)
        }
    }

    @objc func keyboardHidden(notification: NSNotification) {
        self.containerHeight.constant = 600
        self.keyboardFrame = nil
    }

    @IBAction func editingBegan(sender: AnyObject) {
        self.currentField = sender as? UITextField
        if let field = self.currentField, let frame = self.keyboardFrame {
            self.scrollToField(field: field, keyboardFrame: frame)
        }
    }

    @IBAction func editingEnded(sender: AnyObject) {
        self.currentField = nil
    }

    @IBAction func nextField(sender: AnyObject) {
        let field = sender as! UITextField
        _ = field.tag
        var nextTag = field.tag + 1
        if !(600...603 ~= nextTag) {
            nextTag = 600
        }
        if let next = self.view.viewWithTag(nextTag) as? UITextField, let frame = self.keyboardFrame {
            next.becomeFirstResponder()
            self.scrollToField(field: next, keyboardFrame: frame)
        }
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        hideKeyboard()
        
        
        if let idToken = SessionManager.instance.getAccessToken() {
           
            Auth0
                .users(token: idToken)
                .patch("user identifier", userMetadata:  [
                    MetadataKeys.GivenName.rawValue: self.firstName.text!,
                    MetadataKeys.FamilyName.rawValue: self.lastName.text!,
                    MetadataKeys.Address.rawValue: self.address.text!,
                    MetadataKeys.Birthday.rawValue: self.birthday.text!,
                    ])
                .start { result in
                    switch result {
                    case .success( _):
                        MessageBox.show( "User Info Saved succesfully")
                        
                    case .failure(let error):
                        MessageBox.showError( error.localizedDescription )
                    }
            }
        }
    }

    private func hideKeyboard() {
        self.currentField?.resignFirstResponder()
    }

    private func scrollToField(field: UITextField, keyboardFrame: CGRect) {
        let scrollOffset = self.offsetForFrame(frame: field.frame, keyboardFrame: keyboardFrame)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
    }

    private func offsetForFrame(frame: CGRect, keyboardFrame: CGRect) -> CGFloat {
        let bottom = frame.origin.y + frame.size.height
        let offset = bottom - keyboardFrame.origin.y
        if offset < 0 {
            return 0
        }
        return offset
    }

    private func updateUI() {
        self.title = self.profile.name
        self.avatar.setImageWith(self.profile.pictureURL)
        self.firstName.text = self.profile.givenName
        self.lastName.text = self.profile.familyName
        self.email.text = self.profile.email
        self.address.text = self.profile.userMetadata["address"] as? String
        self.birthday.text = self.profile.userMetadata["birthday"] as? String
    }
}

enum MetadataKeys: String {
    case Username = "username", GivenName = "given_name", FamilyName = "family_name", Birthday = "birthday", Address = "address"
}


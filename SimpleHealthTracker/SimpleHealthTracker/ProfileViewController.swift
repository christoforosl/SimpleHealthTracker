// ProfileViewController.swift
//
// Copyright (c) 2015 Auth0 (http://auth0.com)

import UIKit

class ProfileViewController: UIViewController {
    
    
    @IBOutlet var test: [UIImageView]!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.lastName.text = SessionManager.instance.profile?.familyName
        self.firstName.text = SessionManager.instance.profile?.givenName
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

}


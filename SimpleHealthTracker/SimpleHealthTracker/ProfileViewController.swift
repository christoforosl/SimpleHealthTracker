// ProfileViewController.swift
//
// Copyright (c) 2015 Auth0 (http://auth0.com)

import UIKit

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var btnLogout: UIButton!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.btnLogout.addTarget(self, action: #selector(doLogout), for: .touchUpInside)

    }
    
    func loadData() {
        self.lastName.text = SessionManager.instance.profile?.familyName
        self.firstName.text = SessionManager.instance.profile?.givenName
        self.txtEmail.text = SessionManager.instance.profile?.email
        self.avatar.loadFromUrl(url: SessionManager.instance.getProfileImageURL())
    }
    
    @objc func doLogout() {
        SessionManager.instance.logout()
        self.showUIForLoginNeeded( callbackAfterLogin: {
            self.loadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

}


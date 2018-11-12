//
//  FirstViewController.swift
//  SimplestHealthTracker
//
//  Created by Chris on 24/10/2018.
//  Copyright © 2018 CGL. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        // if the user is not logged in we need to show the not logged in overlay
        // and allow the user to login
        let loginStatus = SessionManager.instance.getStatus();
        if loginStatus == EnumSessionManagerStatus.notLoggedIn {
            self.showUIForLoginNeeded()
        } else  {
     
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


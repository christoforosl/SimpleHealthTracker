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
        self.checkTokenAndLoginIfNoToken(callbackAfterLogin: { x in
            
        })
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


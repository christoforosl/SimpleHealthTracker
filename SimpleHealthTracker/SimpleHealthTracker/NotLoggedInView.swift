//
//  TestView.swift
//  Marbyl
//
//  Created by Christoforos Lambrou on 5/21/18.
//  Copyright © 2018 Christoforos Lambrou. All rights reserved.
//

import UIKit
import ActiveLabel

class NotLoggedInView: UIView {
    
    @IBOutlet weak var PleaseSignIn: UILabel!

    @IBOutlet var ContentView: UIView!
    
    let notLoggedInActivelabelFactory = NotLoggedInLabelFactory()
    var notLoggedInActivelabel:ActiveLabel?
    
    @IBOutlet weak var backHomeButton: UIButton!
    
    open func handleSignInOrSignUp(_ handler: @escaping () -> ()) {
        
        notLoggedInActivelabelFactory.handleSignInOrSignUp {
            handler()
        }
    
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        
        self.ContentView = NotLoggedInView.loadFromXib(withOwner:self);
        
        self.addSubview(self.ContentView)
        self.bringSubview(toFront: self.ContentView)
        
        self.ContentView.frame = self.bounds;
        self.ContentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        self.notLoggedInActivelabel = notLoggedInActivelabelFactory.getNotLoggedinLabel();
        self.notLoggedInActivelabel?.frame = self.PleaseSignIn.frame
        self.notLoggedInActivelabel?.isHidden = false
        self.PleaseSignIn.isHidden = true
        self.ContentView.addSubview(self.notLoggedInActivelabel!)
        self.ContentView.bringSubview(toFront: self.notLoggedInActivelabel!)

        self.ContentView.bringSubview(toFront: self.backHomeButton)
        
    }
  
    
}

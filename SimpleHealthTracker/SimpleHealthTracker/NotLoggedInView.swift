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
public extension UIView {
    //https://stackoverflow.com/questions/35659714/loading-a-xib-file-to-a-uiview-swift
    // load an xib into a view
    // sample usage
    // let view = CustomView.loadFromXib()
    // let view = CustomView.loadFromXib(withOwner: self)
    // let view = CustomView.loadFromXib(withOwner: self, options: [UINibExternalObjects: objects])
    static func loadFromXib<T>(withOwner: Any? = nil, options: [AnyHashable : Any]? = nil) -> T where T: UIView {
        
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "\(self)", bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: withOwner, options: options).first as? T else {
            fatalError("Could not load view from nib file.")
        }
        return view
    }
    
}


public class NotLoggedInLabelFactory {
    
    internal var SignInOrSignUpHandler: (() -> ())?
    var labelText: String
    
    // MARK: - init functions
    public init() {
        labelText = "Signin Or Signup"
    }
    
    open func handleSignInOrSignUp(_ handler: @escaping () -> ()) {
        self.SignInOrSignUpHandler = handler
    }
    
    func getNotLoggedinLabel()->ActiveLabel {
        
        let notLoggedInActivelabel = ActiveLabel()
        notLoggedInActivelabel.textAlignment = NSTextAlignment.center
        
        let customType = ActiveType.custom(pattern: "Sign In") // ActiveType.custom(pattern: "Sign in Or Register") //Looks for "are"
        let customType2 = ActiveType.custom(pattern: "Sign Up") // ActiveType.custom(pattern: "Sign in Or Register") //Looks for "are"
        
        notLoggedInActivelabel.enabledTypes.append(customType)
        notLoggedInActivelabel.enabledTypes.append(customType2)
        //https://github.com/optonaut/ActiveLabel.swift/blob/master/ActiveLabelDemo/ViewController.swift
        notLoggedInActivelabel.isUserInteractionEnabled = true
        notLoggedInActivelabel.enabledTypes = [customType,customType2]
        notLoggedInActivelabel.accessibilityIdentifier = "notLoggedInActivelabel"
        
        notLoggedInActivelabel.customize { label in
            label.text = labelText;
            label.numberOfLines = 0
            label.lineSpacing = 4
            label.textColor = UIColor.darkGray
            label.customColor[customType] = UIColor.purple
            label.customSelectedColor[customType] = UIColor.green
            label.customColor[customType2] = UIColor.purple
            label.customSelectedColor[customType2] = UIColor.green
            
            label.handleCustomTap(for: customType) { element in
                guard let handler = self.SignInOrSignUpHandler else {
                    return
                }
                handler()
            }
            label.handleCustomTap(for: customType2) { element in
                guard let handler = self.SignInOrSignUpHandler else {
                    return
                }
                handler()
            }
            
        }
        return notLoggedInActivelabel
    }
    
    
}




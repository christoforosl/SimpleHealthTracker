//
//  Created by Christoforos Lambrou on 6/10/17.
//  Copyright © 2017 Christoforos Lambrou. All rights reserved.
//

import UIKit
import Lock

public enum EnumLoginResult {
    case cancelled
    case loggedin
    case error
    case newUserSignup
}

extension UIViewController {

    // check if we have a logged in user, and if not show the login screen.
    // Run the callback only after successful login or if we had a user to begin with.
    func requireLogin( callback: @escaping () -> ()) {
        if SessionManager.instance.getStatus() == EnumSessionManagerStatus.loggedInWithProfile {
            callback();
        } else {
            self.showLogin(callback: { result in
                if result == EnumLoginResult.loggedin {
                    callback();
                } else {
                    MessageBox.showError("A Valid Login is Required for this action.");
                }
            })
        }
    }
    
    @objc func goHome(){
        
        self.tabBarController?.selectedIndex = 0
        
    }
    
    /**
    * overlays the notLoggedInView onto the current view.
    **/
    func showUIForLoginNeeded() -> Void {
        
        DispatchQueue.main.async {
            let nlview = NotLoggedInView(frame:self.view.frame)
            
            nlview.backHomeButton.addTarget(self, action: #selector( self.goHome ), for: .touchUpInside)
            nlview.translatesAutoresizingMaskIntoConstraints = true
            nlview.autoresizingMask = []
            nlview.frame = self.view.frame
            nlview.handleSignInOrSignUp({
                self.showLogin(callback: {result in
                    if result == EnumLoginResult.loggedin {
                        nlview.removeFromSuperview()
                    }
                })
            })
            self.view.addSubview(nlview);
            self.view.bringSubview(toFront: nlview)
        }
    }
    
    // check status of user login, and show the login screen.
    // call callback after sucessfull login or login, passing the result
    func checkTokenAndLoginIfNoToken( callback: @escaping (EnumLoginResult) -> ()) {
    
        if SessionManager.instance.getStatus() == EnumSessionManagerStatus.loggedInNotProfile {
            
            // try to retrieve the profile using the stored session variable
            SessionManager.instance.retrieveProfile { error in
                DispatchQueue.main.async {
                    if (error != nil)  {
                        print( "Error: \(error.debugDescription)")
                        return self.showLogin(callback: callback)
                    } else {
                        callback(EnumLoginResult.loggedin)
                    }
                }
            }
        } else if SessionManager.instance.getStatus() == EnumSessionManagerStatus.loggedInWithProfile {
            callback(EnumLoginResult.loggedin)
            
        } else if SessionManager.instance.getStatus() == EnumSessionManagerStatus.notLoggedIn {
            return self.showLogin(callback: callback)
        }
        
    }
    
    func showLogin(callback: @escaping (EnumLoginResult) ->Void ) {
        
        let imageName = "Auth0-marbyl-logo"; 
        Lock
            .classic()
            .withStyle {
                $0.title = "Simple Health Tracker"
                $0.logo = LazyImage(name: imageName)
                $0.headerColor = UIColor.black
                $0.titleColor = UIColor.white
            }
            .withOptions {
                $0.closable = true
                $0.scope = "openid profile name email picture offline_access"
                $0.logLevel = .error
                $0.logHttpRequest = true
                $0.customSignupFields = [
                    CustomTextField(name: "firstname", placeholder: "First Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle)),
                    CustomTextField(name: "lastname", placeholder: "Last Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle))
                ]
            }
            .onAuth { credentials in
                // Save the Credentials object
                
                guard let accessToken = credentials.accessToken, let refreshToken = credentials.refreshToken else {
                    let msg = "Oh No! Got error in credentials.accessToken or refreshToken :-( "
                    
                    print(msg)
                    return
                    
                }
                
                SessionManager.instance.storeTokens(accessToken, refreshToken: refreshToken)
                
                SessionManager.instance.retrieveProfile { error in
                    DispatchQueue.main.async {
                        if( error != nil ) {
                            let msg = "Oh No! Got error \(error.debugDescription) in retrieveProfile :-( "
                            print(msg)
                            MessageBox.showError(msg )
                            
                            return
                        } else {
                            // print("------> Logged in success!!  <------------ " )
                            callback( EnumLoginResult.loggedin )

                        }
                    }
                }
                
            }
            .onSignUp { email, attributes in
                print("New user with email \(email)!")
                callback(EnumLoginResult.newUserSignup)
            }
            .onCancel {
                callback(EnumLoginResult.cancelled)
            }
            .onError { error in
                
                print("Failed with error \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    let msg = "Oh No! Got error \(error.localizedDescription) on AUTH0 :-( "
                    MessageBox.show(msg)
                    print(msg)
                    return
                }
                
            }
            
            .present(from: self)
    }
    

}

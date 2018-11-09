

import UIKit
import Lock
import SimpleKeychain

enum SessionNotification: String {
    case Start = "StartSession"
    case Finish = "FinishSession"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.makeKeyAndVisible()
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoadingController")
        self.window?.rootViewController = controller
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "finishSessionNotification:", name: SessionNotification.Finish.rawValue, object: nil)
        notificationCenter.addObserver(self, selector: "startSessionNotification:", name: SessionNotification.Start.rawValue, object: nil)
        let storage = Application.sharedInstance.storage
        let lock = Application.sharedInstance.lock
        lock.applicationLaunchedWithOptions(launchOptions)
        lock.refreshIdTokenFromStorage(storage) { (error, token) -> () in
            if error != nil {
                self.showLock(false)
                return;
            }
            storage.idToken = token
            self.showMainRoot()
        }
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return Application.sharedInstance.lock.handleURL(url, sourceApplication: sourceApplication)
    }
    
    func startSessionNotification(notification: NSNotification) {
        self.showMainRoot()
    }
    
    func finishSessionNotification(notification: NSNotification) {
        Application.sharedInstance.storage.clear()
        self.showLock(true)
    }
    
    private func showMainRoot() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = controller
        UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionFlipFromLeft, animations: { }, completion: nil)
    }
    
    private func showLock(animated: Bool = false) {
        let storage = Application.sharedInstance.storage
        storage.clear()
        let lock = Application.sharedInstance.lock.newLockViewController()
        lock.onAuthenticationBlock = { (profile, token) in
            switch(profile, token) {
            case let (.Some(profile), .Some(token)):
                storage.save(token: token, profile: profile)
                NSNotificationCenter.defaultCenter().postNotificationName(SessionNotification.Start.rawValue, object: nil)
            default:
                print("Either auth0 token or profile of the user was nil, please check your Auth0 Lock config")
            }
        }
        self.window?.rootViewController = lock
        if animated {
            UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionFlipFromLeft, animations: { }, completion: nil)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


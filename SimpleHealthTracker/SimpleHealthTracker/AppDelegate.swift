

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
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector:#selector(finishSessionNotification), name: NSNotification.Name(rawValue: SessionNotification.Finish.rawValue), object: nil)
        notificationCenter.addObserver(self, selector:#selector(startSessionNotification), name: NSNotification.Name(rawValue: SessionNotification.Start.rawValue), object: nil)
        
        let storage = Application.sharedInstance.storage
        let lock = Application.sharedInstance.lock
        lock.applicationLaunched(options: launchOptions)
        lock.refreshIdTokenFromStorage(storage: storage) { (error, token) -> () in
            if error != nil {
                self.showLock(animated: false)
                return;
            }
            storage.idToken = token
            self.showMainRoot()
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return Application.sharedInstance.lock.handle(url, sourceApplication: sourceApplication)
    }
    
    @objc func startSessionNotification(notification: NSNotification) {
        self.showMainRoot()
    }
    
    @objc func finishSessionNotification(notification: NSNotification) {
        Application.sharedInstance.storage.clear()
        self.showLock(animated: true)
    }
    
    private func showMainRoot() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = controller
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: { }, completion: nil)
    }
    
    private func showLock(animated: Bool = false) {
        let storage = Application.sharedInstance.storage
        storage.clear()
        let lock = Application.sharedInstance.lock.newLockViewController()
        lock?.onAuthenticationBlock = { (profile, token) in
            switch(profile, token) {
            case let (.some(profile), .some(token)):
                storage.save(token: token, profile: profile)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SessionNotification.Start.rawValue), object: nil)
            default:
                print("Either auth0 token or profile of the user was nil, please check your Auth0 Lock config")
            }
        }
        self.window?.rootViewController = lock
        if animated {
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: { }, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


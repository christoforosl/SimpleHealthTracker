// SessionManager.swift
// Auth0Sample
// Copyright (c) 2016 Auth0 (http://auth0.com)
//

import Foundation
import SimpleKeychain
import Auth0

enum SessionManagerError: Error {
    case noAccessToken
    case noRefreshToken
}

enum EnumSessionManagerStatus {
    case notLoggedIn // user is not logged in
    case loggedInWithNoProfile // user is logged in but no profile is present
    case loggedInWithProfile // user logged in with profile
}

class SessionManager {
    
    private static let ACCESS_TOKEN_NAME = "access_token"
	private static let REFRESH_TOKEN_NAME = "refresh_token"
	
    public static let instance = SessionManager()
    
    private let keychain = A0SimpleKeychain(service: "Auth0")
    private var _profile: Profile?
    
    private var profileImage: UIImage?
    
    private init () {
    
    }
    
    public var profile:Profile? {
        get {
            return self._profile
        }
        set {
            self._profile = newValue
        }
    }
    
    func getStatus() -> EnumSessionManagerStatus {
        if self.profile != nil {
            // this is the case where the user has logged in and the profile has been retrieved.
            return EnumSessionManagerStatus.loggedInWithProfile
        } else {
            if self.getAccessToken() != nil {
                // this is the case where we have a user from a previous session of the app.
                return EnumSessionManagerStatus.loggedInWithNoProfile
            } else {
                return EnumSessionManagerStatus.notLoggedIn
                // no profile and no saved access token from previos session
            }
        }
    }
    
    func getProfileImageURL() ->URL? {
        let url = URL(string: (self.profile?.pictureURL.absoluteString)!)
        return url
    }
    
    func getProfileImage() -> UIImage {
        if(self.profileImage == nil) {
            self.fetchProfileImage()
        }
        return self.profileImage!;
        
    }
    
    func fetchProfileImage() -> Void {
    
        let url = URL(string: (self.profile?.pictureURL.absoluteString)!)
        let data = try? Data(contentsOf: url!)
        
        if data != nil {
            self.profileImage = UIImage(data: data!)
        }
    }
    
    func storeTokens(_ accessToken: String, refreshToken: String? = nil) {
        self.keychain.setString(accessToken, forKey: SessionManager.ACCESS_TOKEN_NAME)
        if let refreshToken = refreshToken {
            self.keychain.setString(refreshToken, forKey: SessionManager.REFRESH_TOKEN_NAME)
        }
    }

    func getPreferredLanguage()->String? {
        if let ret = self.keychain.string(forKey: "preferredLanguage") {
            return ret;
        } else {
            return "en";
        }
    }

    func getAccessToken() -> String? {
        guard let accessToken = self.keychain.string(forKey: SessionManager.ACCESS_TOKEN_NAME) else {
            return nil;
        }
        return accessToken;
    }
    
    
    //retrieve profile using stored access token
    func retrieveProfile( callback: @escaping (Error?) -> ()) {
        
        guard let accessToken = self.keychain.string(forKey: SessionManager.ACCESS_TOKEN_NAME) else {
            return callback(SessionManagerError.noAccessToken) // this should never happen :-)
        }
        
        Auth0
            .authentication()
            .userInfo(token: accessToken)
            .start { result in
                switch(result) {
                
                case .success(let profile):
                    self.profile = profile
                    callback(nil)
                    
                case .failure(_):
                    self.keychain.deleteEntry(forKey: SessionManager.ACCESS_TOKEN_NAME);
                    callback(SessionManagerError.noAccessToken)
                }
        }
    }
    
    // call the localstorage and retrieve the refreshToken.
    // if found, call Auth0 renew else call signin/signup sequence
    func refreshToken(_ callback: @escaping (Error?) -> ()) {
        
        guard let refreshToken = self.keychain.string(forKey: SessionManager.REFRESH_TOKEN_NAME) else {
            return callback(SessionManagerError.noRefreshToken)
        }
        Auth0
            .authentication()
            .renew(withRefreshToken: refreshToken, scope: "openid profile offline_access")
            .start { result in
                switch(result) {
                
                case .success(let credentials):
                    guard let accessToken = credentials.accessToken else {
                        return
                    }
                    self.storeTokens(accessToken)
                    self.retrieveProfile(callback: callback)
                
                case .failure(let error):
                    callback(error)
                    self.logout()
                }
        }
    }

    func logout() {
        self.profile = nil;
        self.keychain.clearAll()
        MessageBox.show("You were Logged Out!!, Bye Bye now :-)")
        
    }
    
}

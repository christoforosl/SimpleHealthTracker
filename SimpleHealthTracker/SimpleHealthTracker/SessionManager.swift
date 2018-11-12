// SessionManager.swift
// Auth0Sample
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SimpleKeychain
import Auth0

enum SessionManagerError: Error {
    case noAccessToken
    case noRefreshToken
}

enum EnumSessionManagerStatus {
    case notLoggedIn
    case loggedInNotProfile
    case loggedInWithProfile
}

class SessionManager {
    
    private static let USER_URL_ID = "USER_URL_ID"
    private static let ACCESS_TOKEN_NAME = "access_token"
	private static let REFRESH_TOKEN_NAME = "refresh_token"
	
    static let instance = SessionManager()
    let keychain = A0SimpleKeychain(service: "Auth0")
    var profile: Profile?
    
    private var profileImage: UIImage?
    
    private init () {
    
    }
    
    func getStatus() -> EnumSessionManagerStatus {
        if self.profile != nil {
            // this is the case where the user has logged in and the profile has been retrieved.
            return EnumSessionManagerStatus.loggedInWithProfile
        } else {
            if self.getAccessToken() != nil {
                // this is the case where we have a user from a previous session of the app.
                return EnumSessionManagerStatus.loggedInNotProfile
            } else {
                return EnumSessionManagerStatus.notLoggedIn
                // no profile and no saved access token from previos session
            }
        }
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

    func setUrlId(_ urlId: String) {
        self.keychain.setString(urlId, forKey: SessionManager.USER_URL_ID)
        
    }
    
    func getUrlId()->String? {
        if let ret = self.keychain.string(forKey: SessionManager.USER_URL_ID) {
            return ret
        } else {
            return nil
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
        print ("Application Logged Out!!")
        
    }
    
}

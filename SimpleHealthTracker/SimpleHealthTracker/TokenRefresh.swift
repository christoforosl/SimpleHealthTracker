//
//  TokenRefresh.swift
//  SwiftSample
//
//  Created by Hernan Zalazar on 6/23/15.
//  Copyright (c) 2015 Auth0. All rights reserved.
//

import Foundation
import Lock
import JWTDecode

public class TokenRefresh: NSObject {

    let storage: Storage
    let client: A0APIClient

    public init(storage: Storage, client: A0APIClient) {
        self.storage = storage
        self.client = client
    }

    public func refresh(callback: @escaping ( NSError?,  String?) -> ()) {
        if let jwt = storage.idToken {
            do {
                let jwtDecoded = try decode(jwt: jwt)
                if !jwtDecoded.expired {
                    callback( nil, storage.idToken)
                    return
                }
                if let refreshToken = storage.refreshToken {
                    client.fetchNewIdToken(withRefreshToken: refreshToken, parameters: nil, success: { (token) -> () in
                        callback( nil, token.idToken)
                        }, failure: { (error) -> () in
                            callback( error as NSError,  nil)
                    })
                } else {
                    callback(NSError(domain: "com.auth0.ios.refresh-token", code: -1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Couldn't find a refresh token in Token Storage", comment: "No refresh_token")]), nil)
                }
            } catch {
                callback( NSError(domain: "com.auth0.ios.id-token", code: -1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Couldn't decode the id_token found in Token Storage", comment: "Error in  id_token")]),  nil)
            }
            
        } else {
            callback( NSError(domain: "com.auth0.ios.id-token", code: -1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Couldn't find an id_token in Token Storage", comment: "No id_token")]),  nil)
        }
    }

}

public extension A0Lock {
    public func refreshIdTokenFromStorage(storage: Storage, callback: @escaping (NSError?,  String?) -> ()) {
        let token = TokenRefresh(storage: storage, client: self.apiClient())
        token.refresh(callback: callback)
    }
}

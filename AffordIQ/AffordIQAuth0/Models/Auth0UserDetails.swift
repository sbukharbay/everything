//
//  Auth0UserDetails.swift
//  AffordIQAuth0
//
//  Created by Sultangazy Bukharbay on 19/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Auth0

struct Auth0UserDetails: UserDetails {
    let profile: Auth0.UserInfo
    
    init(profile: Auth0.UserInfo) {
        self.profile = profile
    }
    
    var name: String {
        return profile.name ?? ""
    }
    
    var givenName: String {
        return profile.givenName ?? ""
    }
    
    var username: String {
        return email
    }
    
    var locale: String {
        return profile.locale?.identifier ?? "en_GB"
    }
    
    var familyName: String {
        return profile.familyName ?? ""
    }
    
    var email: String {
        return profile.email ?? ""
    }
    
    var externalUserId: String {
        get {
            return profile.sub.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        } set {
            print(newValue)
        }
    }
}

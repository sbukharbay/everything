//
//  Environment.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct Environment {
    public static var shared: Environment!
    
    public let baseURL: URL
    public let issuerURI: URL
    public let openBankingURL: URL
    
    public let sessionConfiguration: SessionConfiguration
    
    public static func setup(bundle: Bundle) {
        Environment.shared = Environment(bundle: bundle)
    }
    
    private init?(bundle: Bundle) {
        guard
            let infoDictionary = bundle.infoDictionary,
            let environment = infoDictionary["Environment"] as? [String: Any],
            let baseURL = URLComponents(uri: environment["BaseURI"] as? String,
                                        port: environment["BasePort"] as? String).url,
            let clientId = environment["ClientID"] as? String,
            let webClientSecret = environment["WebClientSecret"] as? String,
            let webClientId = environment["WebClientID"] as? String,
            let webGrantType = environment["WebGrantType"] as? String,
            let issuer = URLComponents(uri: environment["IssuerURI"] as? String).url,
            let scopes = (environment["Scopes"] as? String)?.components(separatedBy: CharacterSet.whitespaces),
            let redirectURI = environment["RedirectURI"] as? String,
            let logoutRedirectURI = environment["LogoutURI"] as? String,
            let openBankingURL = URLComponents(uri: environment["OpenBankingURI"] as? String).url
        else {
            return nil
        }
        
        let audienceUri = environment["AudienceURI"] as? String ?? ""
        
        let bundleSessionConfiguration = SessionConfiguration(clientId: clientId,
                                                              issuer: issuer.absoluteString,
                                                              scopes: scopes,
                                                              redirectUri: redirectURI,
                                                              logoutRedirectUri: logoutRedirectURI,
                                                              audienceUri: audienceUri,
                                                              webClientSecret: webClientSecret,
                                                              webClientId: webClientId,
                                                              webGrantType: webGrantType)
        
        self.init(baseURL: baseURL,
                  openBankingURL: openBankingURL,
                  issuerURI: issuer,
                  sessionConfiguration: bundleSessionConfiguration)
    }
    
    private init(baseURL: URL, openBankingURL: URL, issuerURI: URL, sessionConfiguration: SessionConfiguration) {
        self.baseURL = baseURL
        self.openBankingURL = openBankingURL
        self.issuerURI = issuerURI
        self.sessionConfiguration = sessionConfiguration
    }
}

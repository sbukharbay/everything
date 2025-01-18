//
//  AdaptableNetwork.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public class AdaptableNetwork<SomeRouter: RequestConvertible>: NetworkManager {
    public typealias Router = SomeRouter
    
    public lazy var session: URLSession = {
        let session = URLSession(
            configuration: configuration,
            delegate: certificateManager,
            delegateQueue: OperationQueue()
        )
        
        return session
    }()
    private let configuration: URLSessionConfiguration
    private weak var certificateManager: CertificateManager?
    
    public init() {
        configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = true
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.onlyFromMainDocumentDomain
        configuration.httpCookieStorage?.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.onlyFromMainDocumentDomain
        
        let certificateManager = CertificateManager()
        self.certificateManager = certificateManager
    }
    
    deinit {
        print("[AdaptableNetwork] Finish tasks and invalidate session")
    }
}

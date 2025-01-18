//
//  CertificateManager.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class CertificateManager: NSObject {
    static let rootCertificates: CFArray = {
        let bundle = Bundle(for: CertificateManager.self)
        let derCertificateURLs = bundle.urls(forResourcesWithExtension: "cer", subdirectory: nil, localization: nil) ?? []
        let crtCertificateURLs = bundle.urls(forResourcesWithExtension: "crt", subdirectory: nil, localization: nil) ?? []
        
        let certificateURLs = derCertificateURLs + crtCertificateURLs
        
        let result: [SecCertificate] = certificateURLs.compactMap {
            if let data = try? Data(contentsOf: $0) {
                let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData)
                return certificate
            }
            return nil
        }
        
        #if DEBUG
        let subjects = result.compactMap { SecCertificateCopySubjectSummary($0) }.map { $0 as String }
        print("Using root certificates:")
        let separator = "\n\t• "
        print("\t• " + subjects.joined(separator: separator))
        #endif
        
        if result.isEmpty {
            fatalError("No SSL root CAs defined.")
        }
        
        return result as CFArray
    }()
}

extension CertificateManager: URLSessionDelegate {
    public func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            SecTrustSetAnchorCertificates(serverTrust, CertificateManager.rootCertificates)
            SecTrustSetAnchorCertificatesOnly(serverTrust, true)
            
            var trustError: CFError?
            let ok = SecTrustEvaluateWithError(serverTrust, &trustError)
            
            if ok {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            } else {
                #if DEBUG
                if let trustError = trustError {
                    debugPrint(trustError)
                }
                #endif
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

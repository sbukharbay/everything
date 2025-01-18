//
//  OpenBankingAuthorizationCoordinator.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 30/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import AuthenticationServices
import SafariServices
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0

public protocol OpenBankingAuthorizationDelegate: AnyObject {
    func didCompleteAuthorization(institutionId: String?, request: RMAuthoriseBank?)
    func didCancelAuthorization()
}

class OpenBankingAuthorizationCoordinator: NSObject {
    weak var presenter: UINavigationController?
    weak var delegate: OpenBankingAuthorizationDelegate?
    var errorPresenter: ErrorPresenter
    let institutionId: String

    init(presenter: UINavigationController, institutionId: String, delegate: OpenBankingAuthorizationDelegate, errorPresenter: ErrorPresenter) {
        self.presenter = presenter
        self.institutionId = institutionId
        self.delegate = delegate
        self.errorPresenter = errorPresenter
    }
}

extension OpenBankingAuthorizationCoordinator: Coordinator {
    func start() {
        if let presenter = presenter, let delegate = delegate {
            Task {
                await authorise(presenter: presenter, institutionId: institutionId, delegate: delegate, errorPresenter: errorPresenter)
            }
        }
    }
}

public class HolderView: NSObject {
    public var providerId: String?
    var delegate: OpenBankingAuthorizationDelegate?
    var authenticationSession: ASWebAuthenticationSession?

    public static var shared: HolderView = .init()

    public func next(url: String) {
        if let session = authenticationSession {
            session.cancel()
        }

        if let delegate = delegate {
            let code = getQueryStringParameter(url: url, param: "code") ?? ""
            let scope = getQueryStringParameter(url: url, param: "scope") ?? ""
            let state = getQueryStringParameter(url: url, param: "state") ?? ""

            delegate.didCompleteAuthorization(institutionId: providerId, request: RMAuthoriseBank(code: code, scope: scope, state: state, providerID: providerId ?? ""))
        }
    }
}

extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

private func userCancelledAuthorization(error: Error) -> Bool {
    let nsError = error as NSError
    return nsError.domain == ASWebAuthenticationSessionErrorDomain
        && nsError.code == 1
}

public func authenticate(presenter: UINavigationController,
                         authoriseURL: URL,
                         delegate: OpenBankingAuthorizationDelegate,
                         errorPresenter: ErrorPresenter) {
    let id = getQueryStringParameter(url: authoriseURL.absoluteString, param: "provider_id") ?? ""
    
    let authenticationSession = ASWebAuthenticationSession(url: authoriseURL, callbackURLScheme: "ioblackarrowgroupopenbanking") { response, error in

        if let url = response {
            syncIfRequired {
                let code = getQueryStringParameter(url: url.absoluteString, param: "code") ?? ""
                let scope = getQueryStringParameter(url: url.absoluteString, param: "scope") ?? ""
                let state = getQueryStringParameter(url: url.absoluteString, param: "state") ?? ""
                delegate.didCompleteAuthorization(institutionId: id, request: RMAuthoriseBank(code: code, scope: scope, state: state, providerID: id))
            }
        }

        if let error = error {
            if userCancelledAuthorization(error: error) {
                delegate.didCancelAuthorization()
            } else {
                errorPresenter.present(error: error)
            }
        }
    }
    let holder = HolderView.shared
    holder.delegate = delegate
    holder.providerId = id
    holder.authenticationSession = authenticationSession

    authenticationSession.prefersEphemeralWebBrowserSession = true
    authenticationSession.presentationContextProvider = presenter
    authenticationSession.start()
}

private func getQueryStringParameter(url: String, param: String) -> String? {
    guard let url = URLComponents(string: url) else { return nil }
    return url.queryItems?.first(where: { $0.name == param })?.value
}

@MainActor
private func authorise(presenter: UINavigationController,
                       institutionId: String,
                       delegate: OpenBankingAuthorizationDelegate,
                       errorPresenter: ErrorPresenter,
                       openBankingSource: OpenBankingSource = OpenBankingService(),
                       session: SessionType = Auth0Session.shared) async {
    guard let userID = session.userID else { return }
    
    do {
        let response = try await openBankingSource.authorise(userID: userID, providerID: institutionId)
        
        if let message = response.message, let authoriseURL = URL(string: message) {
            authenticate(presenter: presenter, authoriseURL: authoriseURL, delegate: delegate, errorPresenter: errorPresenter)
        }
    } catch let error {
        errorPresenter.present(error: error)
    }
}

//
//  SwifterAuth.swift
//  Swifter
//
//  Copyright (c) 2014 Matt Donnelly.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit
import SafariServices

typealias TokenSuccessHandler = (Credential.OAuthAccessToken?, URLResponse) -> Void
typealias FailureHandler = (_ error: Error) -> Void
typealias JSONSuccessHandler = (SwifterJSON, _ response: HTTPURLResponse) -> Void

internal class SwifterAuth {
	
    public var client: SwifterClientProtocol

	internal var swifterCallbackToken: NSObjectProtocol? {
		willSet {
			guard let token = swifterCallbackToken else { return }
			NotificationCenter.default.removeObserver(token)
		}
	}

	internal struct CallbackNotification {
		static let optionsURLKey = "SwifterCallbackNotificationOptionsURLKey"
	}

	public init(consumerKey: String, consumerSecret: String) {
		self.client = OAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret)
	}

    /**
     Begin Authorization with a Callback URL
     
     - Parameter presentFromViewController: The viewController used to present the SFSafariViewController.
     The UIViewController must inherit SFSafariViewControllerDelegate
     
     */
    
    func authorize(withCallback callbackURL: URL,
			presentingFrom presenting: UIViewController?,
			forceLogin: Bool = false,	// Forces the user to enter their credentials to ensure the correct users account is authorized.
			safariDelegate: SFSafariViewControllerDelegate? = nil,
			success: TokenSuccessHandler?,
			failure: FailureHandler? = nil) {

        self.postOAuthRequestToken(with: callbackURL,
        	success: { token, response in
				var requestToken = token!
				self.swifterCallbackToken = NotificationCenter.default.addObserver(forName: .swifterCallback, object: nil, queue: .main) { notification in
					self.swifterCallbackToken = nil
					presenting?.presentedViewController?.dismiss(animated: true, completion: nil)
					let url = notification.userInfo![CallbackNotification.optionsURLKey] as! URL
					
					let parameters = url.query!.queryStringParameters
					requestToken.verifier = parameters["oauth_verifier"]
					
					self.postOAuthAccessToken(with: requestToken,
						success: { accessToken, response in
							self.client.credential = Credential(accessToken: accessToken!)
							success?(accessToken!, response)
						},
						failure: failure)
				}

				let forceLogin = forceLogin ? "&force_login=true" : ""
				let query = "oauth/authorize?oauth_token=\(token!.key)\(forceLogin)"
				let queryUrl = URL(string: query, relativeTo: TwitterURL.oauth.url)!.absoluteURL
				
				if let delegate = safariDelegate ?? (presenting as? SFSafariViewControllerDelegate) {
					let safariView = SFSafariViewController(url: queryUrl)
					safariView.delegate = delegate
					safariView.modalTransitionStyle = .coverVertical
					safariView.modalPresentationStyle = .overFullScreen
					presenting?.present(safariView, animated: true, completion: nil)
				} else {
					UIApplication.shared.open(queryUrl, options: [:], completionHandler: nil)
				}
			},
        	failure: failure)
    }

    @discardableResult
    class func handleOpenURL(_ url: URL, callbackURL: URL) -> Bool {
        guard url.hasSameUrlScheme(as: callbackURL) else {
            return false
        }
        let notification = Notification(name: .swifterCallback, object: nil, userInfo: [CallbackNotification.optionsURLKey: url])
        NotificationCenter.default.post(notification)
        return true
    }
    
    func postOAuthRequestToken(with callbackURL: URL, success: @escaping TokenSuccessHandler, failure: FailureHandler?) {
        let path = "oauth/request_token"
        let parameters =  ["oauth_callback": callbackURL.absoluteString]
        
        self.client.post(path, baseURL: .oauth, parameters: parameters, uploadProgress: nil, downloadProgress: nil, success: { data, response in
            let responseString = String(data: data, encoding: .utf8)!
            let accessToken = Credential.OAuthAccessToken(queryString: responseString)
            success(accessToken, response)
        }, failure: failure)
    }
    
    func postOAuthAccessToken(with requestToken: Credential.OAuthAccessToken, success: @escaping TokenSuccessHandler, failure: FailureHandler?) {
        if let verifier = requestToken.verifier {
            let path =  "oauth/access_token"
            let parameters = ["oauth_token": requestToken.key, "oauth_verifier": verifier]
            
            self.client.post(path, baseURL: .oauth, parameters: parameters, uploadProgress: nil, downloadProgress: nil, success: { data, response in
                
                let responseString = String(data: data, encoding: .utf8)!
                let accessToken = Credential.OAuthAccessToken(queryString: responseString)
                success(accessToken, response)
                
                }, failure: failure)
        } else {
            let error = SwifterError(message: "Bad OAuth response received from server",
									 kind: .badOAuthResponse)
            failure?(error)
        }
    }
}

public enum TwitterURL {
    case api
    case upload
    case stream
    case publish
    case userStream
    case siteStream
    case oauth
    
    var url: URL {
        switch self {
        case .api:          return URL(string: "https://api.twitter.com/1.1/")!
        case .upload:       return URL(string: "https://upload.twitter.com/1.1/")!
        case .stream:       return URL(string: "https://stream.twitter.com/1.1/")!
        case .userStream:   return URL(string: "https://userstream.twitter.com/1.1/")!
        case .siteStream:   return URL(string: "https://sitestream.twitter.com/1.1/")!
        case .oauth:        return URL(string: "https://api.twitter.com/")!
        case .publish:		return URL(string: "https://publish.twitter.com/")!
        }
    }
}

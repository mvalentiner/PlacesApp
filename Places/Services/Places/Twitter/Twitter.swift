//
//  Twitter.swift
//  Places
//
//  Created by Michael Valentiner on 8/27/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

struct Twitter {
	/*
		Step 1: Encode consumer key and secret
			The steps to encode an application’s consumer key and secret into a set of credentials to obtain a bearer token are:
			URL encode the consumer key and the consumer secret according to RFC 1738. Note that at the time of writing, this will not actually change the consumer key and secret, but this step should still be performed in case the format of those values changes in the future.
			Concatenate the encoded consumer key, a colon character ”:”, and the encoded consumer secret into a single string.
			Base64 encode the string from the previous step.
	*/
	internal static let bearerTokenCredentials = "\(TwitterConsumerAPIKey):\(TwitterConsumerAPISecretKey)"
	internal static let bearerTokenCredentialsBase64Encoded = Twitter.bearerTokenCredentials.data(using: .utf8)!.base64EncodedString()

	// Cache the Twitter bearer token and refresh it when we get a invalidToken error.
//	internal static var bearerToken = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%2FAAAAAAAAAAAAAAAAAAAA%3DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	private static let twtrBearerTokenKey = "TwtrBearerToken"
	internal static var bearerToken: String {
		get {
			return UserDefaults.standard.string(forKey: twtrBearerTokenKey) ??
				// If value doesn't exist, initialized with an expired token to force the token to be refreshed.
				"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%2FAAAAAAAAAAAAAAAAAAAA%3DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
		}
		set {
			UserDefaults.standard.setValue(newValue, forKey: twtrBearerTokenKey)
		}
	}
	internal static let invalidTokenError = Float(89.0)

	@UserDefault("twtrCredential", defaultValue: nil) var twtrCredential: Credential?	//Credential.OAuthAccessToken?
}

private struct TwitterServiceName {
	static let serviceName = "TwitterService"
}

extension ServiceRegistryImplementation {
	var twitterService: TwitterService {
		get {
			return serviceWith(name: TwitterServiceName.serviceName) as! TwitterService	// Intentional force unwrapping
		}
	}
}

protocol TwitterService: SOAService {
	func isLoggedIn() -> Bool
	func loginToTwitter(mainCoordinator: MainCoordinatorService)
}

extension TwitterService {
	var serviceName: String {
		get {
			return TwitterServiceName.serviceName
		}
	}

	func loginToTwitter(mainCoordinator: MainCoordinatorService) {
		let failureHandler: (Error) -> Void = { error in
			print("Error == \(error.localizedDescription)")
		}
		let callbackUrl = URL(string: "helioplaces://twitterservice/AuthorizeSuccess")!
		let swifterAuth = SwifterAuth(consumerKey: TwitterConsumerAPIKey, consumerSecret: TwitterConsumerAPISecretKey)
		swifterAuth.authorize(withCallback: callbackUrl, presentingFrom: mainCoordinator.rootController.topViewController, forceLogin: false, safariDelegate: nil,
				success: { accessToken, _ in
					var twtr = Twitter()
					twtr.twtrCredential = swifterAuth.client.credential
					let settingsModel = SettingsDataModel()
					settingsModel.twitterIsActive = true
					mainCoordinator.popToRootController()
					mainCoordinator.navigateToInfoScreen()
				},
				failure: failureHandler)
	}

	func loginToTwitterNEW(mainCoordinator: MainCoordinatorService) {
		// POST oauth / request_token -> GET oauth/authorize -> POST oauth / access_token
		// Obtain OAuthRequestToken
//		TwitterOAuthRequestTokenRequest().getToken() { result in
//			switch (result) {
//			case .failure(let error):
//				print("error = \(error)")
//				break
//			case .success(let token):
				//print("token = \(token)")
				//				let forceLogin = ""	//forceLogin ? "&force_login=true" : ""
				//				let query = "oauth/authorize?oauth_token=\(token)\(forceLogin)"
				//				let queryUrl = URL(string: query, relativeTo: URL(string: "https://api.twitter.com/")!)!.absoluteURL
				//				UIApplication.shared.open(queryUrl, options: [:], completionHandler: nil)
//				TwitterOAuthAuthorizeRequest().load { result in
//					switch (result) {
//					case .failure(let error):
//						print("error = \(error)")
//						break
//					case .success(let token):
//						TwitterOAuthAccessTokenRequest().load { result in
//							switch (result) {
//							case .failure(let error):
//								print("error = \(error)")
//								break
//							case .success(let token):
//								break
//							}
//						}
//					}
//				}
//			}
//		}
	}
}

extension Notification.Name {
    static let swifterCallback = Notification.Name(rawValue: "Swifter.CallbackNotificationName")
}

internal class TwitterServiceImplementation: TwitterService {
	// Register the service.
	@discardableResult
	static func register(isActiveFunc: @escaping () -> Bool, urlRoutingService: inout URLRoutingService) -> TwitterServiceImplementation {
		let service = TwitterServiceImplementation(isActiveFunc, urlRoutingService: &urlRoutingService)
		service.register()
		return service
	}

	func isLoggedIn() -> Bool {
		return Twitter().twtrCredential != nil
	}
	
	let twitterIsActive: () -> Bool
	
	init(_ isActiveFunc: @escaping () -> Bool, urlRoutingService: inout URLRoutingService) {
		twitterIsActive = isActiveFunc
		urlRoutingService.add(handler: handleAuthorizeSuccess, for: "twitterservice")
	}
	
	internal func handleAuthorizeSuccess(url: URL, operation: String, parameters : Dictionary<String, String>) -> Bool {
	
		guard operation == "AuthorizeSuccess" else {
			// Unsupported operation.
			// TODO: handle? log? fatal?
			return false
		}
	
//		guard let accessToken = parameters["oauth_token"] else {
//			// Missing token
//			// TODO: handle? log? fatal?
//			return false
//		}

//		var twitter = Twitter()
//		twitter.twtrAccessToken = accessToken

//		SwifterAuth.handleOpenURL(url, callbackURL: url)
        let notification = Notification(name: .swifterCallback, object: nil, userInfo: [SwifterAuth.CallbackNotification.optionsURLKey: url])
        NotificationCenter.default.post(notification)

		return true
	}
}
//parameters.forEach { (key: String, value: String) in
//	print("key: \(key) == \(value)")
//}

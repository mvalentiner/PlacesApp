//
//  Twitter.swift
//  Places
//
//  Created by Michael Valentiner on 8/27/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation
import SwifteriOS

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
	func loginToTwitter(mainController: MainCoordinatorService)
}

extension TwitterService {
	var serviceName: String {
		get {
			return TwitterServiceName.serviceName
		}
	}

	func loginToTwitter(mainController: MainCoordinatorService) {

		let failureHandler: (Error) -> Void = { error in
//			self.alert(title: "Error", message: error.localizedDescription)
			print("Error == \(error.localizedDescription)")
		}
		let swifter = Swifter(consumerKey: TwitterConsumerAPIKey, consumerSecret: TwitterConsumerAPISecretKey)
//print("accessToken == \(String(describing: swifter.client.credential?.accessToken))")
		let url = URL(string: "helioplaces://twitterAuthorizeSuccess")!
		swifter.authorize(withCallback: url, presentingFrom: mainController.rootController.topViewController, success: { _, _ in
//print("accessToken == \(String(describing: swifter.client.credential?.accessToken))")
			mainController.popToRootController()
		}, failure: failureHandler)
	}
}

internal class TwitterServiceImplementation: TwitterService {
//	// Only define one register function.
//	static func register() {
//		TwitterServiceImplementation().register()
//	}

	// Register the service as a lazy service.
	static func register() {
		ServiceRegistry.add(service: SOALazyService(serviceName: TwitterServiceName.serviceName, serviceGetter: { TwitterServiceImplementation() }))
	}
}

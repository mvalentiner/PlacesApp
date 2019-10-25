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

protocol TwitterService: class, SOAService {
	func isLoggedIn() -> Bool
	func loginToTwitter(mainCoordinator: MainCoordinatorService)
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

internal class TwitterServiceImplementation: TwitterService {

	init(with urlRoutingService: inout URLRoutingService) {
		urlRoutingService.add(handler: handleAuthorizeSuccess, for: "twitterservice")
	}

	// Persistent twtrCredential
	@UserDefault("twtrCredential", defaultValue: nil) var twtrCredential: Credential?

	// SOAService protocol requirements
	var serviceName: String {
		get {
			return TwitterServiceName.serviceName
		}
	}

	@discardableResult
	static func register(with urlRoutingService: inout URLRoutingService) -> TwitterServiceImplementation {
		let service = TwitterServiceImplementation(with: &urlRoutingService)
		service.register()
		return service
	}

	// TwitterService protocol requirements
	
	internal func isLoggedIn() -> Bool {
		return self.twtrCredential != nil
	}

	func loginToTwitter(mainCoordinator: MainCoordinatorService) {
		let failureHandler: (Error) -> Void = { error in
			print("Error == \(error.localizedDescription)")
		}
		let callbackUrl = URL(string: "helioplaces://twitterservice/AuthorizeSuccess")!
		let swifterAuth = SwifterAuth(consumerKey: TwitterConsumerAPIKey, consumerSecret: TwitterConsumerAPISecretKey)
		swifterAuth.authorize(withCallback: callbackUrl, presentingFrom: mainCoordinator.rootController.topViewController, forceLogin: false, safariDelegate: nil,
				success: { accessToken, _ in
					self.twtrCredential = swifterAuth.client.credential
//TODO
					let settingsModel = SettingsDataModel()
					settingsModel.twitterIsActive = true
					mainCoordinator.popToRootController()
					mainCoordinator.navigateToInfoScreen()
				},
				failure: failureHandler)
	}
	
	private func handleAuthorizeSuccess(url: URL, operation: String, parameters : Dictionary<String, String>) -> Bool {
		guard operation == "AuthorizeSuccess" else {
			// Unsupported operation.
			// TODO: handle? log? fatal?
			return false
		}

		SwifterAuth.handleOpenURL(url)

		return true
	}
}

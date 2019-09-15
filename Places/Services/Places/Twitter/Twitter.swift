//
//  Twitter.swift
//  Places
//
//  Created by Michael Valentiner on 8/27/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation

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

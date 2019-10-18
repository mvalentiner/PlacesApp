//
//  TwitterAPIKey.swift
//  Places
//
//  Created by Michael Valentiner on 8/5/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation

/*
	Populate with values from https://developer.twitter.com/en/apps/<your app> -> Keys and tokens
	For more info: https://developer.twitter.com/en/docs/basics/authentication/overview/application-only#issuing-application-only-requests

	Protect these secrets. DO NOT check in to a public github repo.
*/

// Token Credentials:
// Access token === Token === resulting oauth_token
internal let TwitterAccessToken = "<Access token>"
// Access token secret === Token Secret === resulting oauth_token_secret
internal let TwitterAccessTokenSecret = "<Access token secret>"

// Client Credentials:
// App Key === API Key === Consumer API Key === Consumer Key === Customer Key === oauth_consumer_key
internal let TwitterConsumerAPIKey = "<API key>"
// App Key Secret === API Secret Key === Consumer Secret === Consumer Key === Customer Key
internal let TwitterConsumerAPISecretKey = "<API secret key>"

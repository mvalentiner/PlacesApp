//
//  TwitterBearerTokenRequest.swift
//  Places
//
//  Created by Michael Valentiner on 8/25/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation

/*
	From https://developer.twitter.com/en/docs/basics/authentication/overview/application-only#issuing-application-only-requests,
	Step 2: Obtain a bearer token
		The value calculated in step 1 must be exchanged for a bearer token by issuing a request to POST oauth2 / token:
		The request must be a HTTP POST request.
		The request must include an Authorization header with the value of Basic <base64 encoded value from step 1>.
		The request must include a Content-Type header with the value of application/x-www-form-urlencoded;charset=UTF-8.
		The body of the request must be grant_type=client_credentials.
*/
class TwitterBearerTokenRequest: UnauthenticatedJSONRequest {
	var endpointURL: String = "https://api.twitter.com/oauth2/token"

	private let bearerTokenCredentialsBase64Encoded: String

	init(_ bearerTokenCredentialsBase64Encoded: String) {
    	self.bearerTokenCredentialsBase64Encoded = bearerTokenCredentialsBase64Encoded
	}

	func makeRequest(for url: URL) -> URLRequest {
		var request = URLRequest(url: url)
        request.httpMethod = "POST"
		var headers = request.allHTTPHeaderFields ?? [:]
		headers["Authorization"] = "Basic \(bearerTokenCredentialsBase64Encoded)"
		headers["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
		request.allHTTPHeaderFields = headers
		request.httpBody = "grant_type=client_credentials".data(using: .utf8)
		return request
	}

	internal func getToken(onCompletion: @escaping (DecodableRequestResult<String>) -> Void) {
		load { (result) in
			switch result {
			case .failure(let error):
				onCompletion(DecodableRequestResult<String>.failure(error))
				return
			case .success(let json):
				// json == {"token_type" : "bearer", "access_token":"BlahBlahBlah"}
				guard let token = json["access_token"]?.stringValue else {
					onCompletion(DecodableRequestResult<String>.failure(.decodeDataError))
					return
				}
				onCompletion(DecodableRequestResult<String>.success(token))
			}
		}
	}
}

//
//  TwitterAuthenticatedRequest.swift
//  Places
//
//  Created by Michael Valentiner on 8/6/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation

// Cache the Twitter bearer token and refresh it when I get a notAuthenticated error (httpStatus == 401).
private var bearerToken = ""

protocol TwitterAuthenticatedRequest: UnauthenticatedJSONRequest {
}

extension TwitterAuthenticatedRequest {
	func makeRequest(for url: URL) -> URLRequest {
		return URLRequest(url: url)
	}

	internal func load(onCompletion: @escaping (DecodableRequestResult<JSON>) -> Void) {
		_load { (dataRequestResult) in
			switch dataRequestResult {
			case .failure(let error):
				print(#function + " .failure(let error) = \(error)")
				if case .httpStatusError(let statusCode) = error {
					print(#function + " .httpStatusError(let statusCode) = \(statusCode)")
					if statusCode == 401 || statusCode == 403 {
						self.requestTokenAndRetryRequest { x in
							let y = x
							// return decoded data
						}
					}
				}
				onCompletion(DecodableRequestResult<JSON>.failure(error))

			case .success(let data):
				self.decodeData(data, onCompletion: onCompletion)
			}
		}
	}

	internal func shouldContinue(withHTTPStatusCode statusCode : Int) -> Bool {
		guard statusCode == 401 || statusCode == 403 || statusCode < 300 else {
			return false
		}
		return true
	}

	private func requestTokenAndRetryRequest(onCompletion: @escaping (DecodableRequestResult<JSON>) -> Void) {
		TwitterBearerTokenRequest().getToken { (decodableRequestResult) in
			switch decodableRequestResult {
			case .success(let token):
				bearerToken = token
				self.retryRequest { jsonRequestResult in
					onCompletion(jsonRequestResult)
				}

			case .failure(let error):
				onCompletion(DecodableRequestResult<JSON>.failure(error))
			}
		}
	}
	
	private func retryRequest(onCompletion: @escaping (DecodableRequestResult<JSON>) -> Void) {
		_load { (dataRequestResult) in
			switch dataRequestResult {
			case .failure(let error):
				print(#function + " .failure(let error) = \(error)")
				onCompletion(DecodableRequestResult<JSON>.failure(error))
				return
			case .success(let data):
				// Decode the data
				guard let decodedData = self.decode(data) else {
					onCompletion(DecodableRequestResult<JSON>.failure(.decodeDataError))
					return
				}
				// Success
				onCompletion(DecodableRequestResult<JSON>.success(decodedData))
				return
			}
		}
	}

	private func decodeData(_ data: Data, onCompletion: @escaping (DecodableRequestResult<JSON>) -> Void) {
		// Decode the data
		guard let decodedData = self.decode(data) else {
			onCompletion(DecodableRequestResult<JSON>.failure(.decodeDataError))
			return
		}
		// Success
		onCompletion(DecodableRequestResult<JSON>.success(decodedData))
		return
	}
}

/*
	From https://developer.twitter.com/en/docs/basics/authentication/overview/application-only#issuing-application-only-requests,
		Obtain a bearer token
		The value calculated in step 1 must be exchanged for a bearer token by issuing a request to POST oauth2 / token:
		The request must be a HTTP POST request.
		The request must include an Authorization header with the value of Basic <base64 encoded value from step 1>.
		The request must include a Content-Type header with the value of application/x-www-form-urlencoded;charset=UTF-8.
		The body of the request must be grant_type=client_credentials.
*/
class TwitterBearerTokenRequest: UnauthenticatedJSONRequest {
	var endpointURL: String = "https://api.twitter.com/oauth2/token"

	func makeRequest(for url: URL) -> URLRequest {
		var request = URLRequest(url: url)
        request.httpMethod = "POST"
		var headers = request.allHTTPHeaderFields ?? [:]
		headers["Authorization"] = "Basic \(TwitterBearerTokenCredentialsBase64Encoded)"
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

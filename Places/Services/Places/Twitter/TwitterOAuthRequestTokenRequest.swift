//
//  TwitterOAuthRequestTokenRequest.swift
//  Places
//
//  Created by Michael Valentiner on 10/2/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation

/*
	From: https://developer.twitter.com/en/docs/basics/authentication/overview/3-legged-oauth
	Step 1: POST oauth / request_token
	Step 2: GET oauth/authorize
	Step 3: POST oauth / access_token
	Step 4: Using these credentials for app-user required requests

	POST oauth / request_token -> GET oauth/authorize -> POST oauth / access_token
*/

class TwitterOAuthRequestTokenRequest: UnauthenticatedJSONRequest {
	var endpointURL: String {
		get { return "https://api.twitter.com/oauth/request_token"}
	}

	internal func getToken(onCompletion: @escaping (DecodableRequestResult<String>) -> Void) {
		load { (result) in
print("result = \(result)")
			switch result {
			case .failure(let error):
				onCompletion(DecodableRequestResult<String>.failure(error))
				return
			case .success(let json):
print("json = \(json)")
//				public init(queryString: String) {
//					let attributes = queryString.queryStringParameters
//
//					self.key = attributes["oauth_token"]!
//					self.secret = attributes["oauth_token_secret"]!
//
//					self.screenName = attributes["screen_name"]
//					self.userID = attributes["user_id"]
//				}

				guard let token = json["access_token"]?.stringValue else {
					onCompletion(DecodableRequestResult<String>.failure(.decodeDataError))
					return
				}
				onCompletion(DecodableRequestResult<String>.success(token))
			}
		}
	}

	func makeRequest(for url: URL) -> URLRequest {
		var request = URLRequest(url: url)

		var headers = request.allHTTPHeaderFields ?? [:]
		headers["Authorization"] = createOAuthHeaderString(method: request.httpMethod!, url: url, callbackUrl: "helioplaces://twitterservice/AuthorizeSuccess")
		headers["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
		request.allHTTPHeaderFields = headers
//print(#function + "headers = \(headers)")
		return request
	}

	private func createOAuthHeaderString(method: String, url: URL, callbackUrl: String) -> String {
		var params: [String: String] = [:]
        params["oauth_callback"] = callbackUrl
		params["oauth_consumer_key"] = TwitterConsumerAPIKey
		params["oauth_nonce"] = UUID().uuidString
		params["oauth_signature_method"] = "HMAC-SHA1"
		params["oauth_timestamp"] = String(Date().timeIntervalSince1970)
//		params["oauth_token"] = "1158238773878149120-HJTFZLz3oinJI34QyuY5bccmjisGLs"
		params["oauth_version"] = "1.0"
		params["oauth_signature"] = createSignature(
			method: method, url: url, requestBody: "", consumerKey: params["oauth_consumer_key"]!,
			nonce: params["oauth_nonce"]!, timestamp: params["oauth_timestamp"]!)	//, token: params["oauth_token"]!)

		let allowedCharacters = CharacterSet.letters.union(CharacterSet.decimalDigits).union(CharacterSet(charactersIn: "-._~"))
//print(#function + "params == \(params)")
		let headerString = params.reduce("") { (resultSoFar, param) -> String in
			let encodedKey = param.key.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
			let encodedValue = param.value.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
			let paramString = "\(encodedKey)=\"\(encodedValue)\""
			guard resultSoFar != "" else {
				return "OAuth \(paramString)"
			}
			return "\(resultSoFar), \(paramString)"
		}
//print(#function + "headerString == \(headerString)")

		return headerString
	}
    
//	authorizationParameters["oauth_signature"] = self.oauthSignature(
//		for: method, url: url, parameters: finalParameters, accessToken: self.credential?.accessToken)
    func oauthSignature(for method: HTTPMethodType, url: URL, parameters: [String: Any], accessToken token: Credential.OAuthAccessToken?) -> String {
        let tokenSecret = token?.secret.urlEncodedString() ?? ""
        let encodedConsumerSecret = self.consumerSecret.urlEncodedString()
        let signingKey = "\(encodedConsumerSecret)&\(tokenSecret)"
        let parameterComponents = parameters.urlEncodedQueryString(using: dataEncoding).components(separatedBy: "&").sorted()
        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = parameterString.urlEncodedString()
        let encodedURL = url.absoluteString.urlEncodedString()
        let signatureBaseString = "\(method)&\(encodedURL)&\(encodedParameterString)"
        
        let key = signingKey.data(using: .utf8)!
        let msg = signatureBaseString.data(using: .utf8)!
        let sha1 = HMAC.sha1(key: key, message: msg)!
        return sha1.base64EncodedString(options: [])
    }

	/*
		https://developer.twitter.com/en/docs/basics/authentication/guides/creating-a-signature.html
	*/
	private func createSignature(
		method: String,
		url: URL,
		requestBody: String,
		consumerKey: String,
		nonce: String,
		timestamp: String
/*		token: String */) -> String {

		//* The base URL is the URL to which the request is directed, minus any query string or hash parameters.
		let baseUrl: String = { (url: URL) in
			guard let queryStartIndex = url.absoluteString.firstIndex(of: "?") else {
				return url.absoluteString
			}
			return String(url.absoluteString.prefix(upTo: queryStartIndex))
		}(url)

		//* Gather all of the parameters included in the request.
		var queryParams = [String: String]()
		if let queryString = url.query {
			let components = queryString.components(separatedBy: "&")
			queryParams = components.map { (component) -> [String:String] in
				let keyValue = component.components(separatedBy: "=")
				return [keyValue[0]:keyValue[1]]
			}
			.first ?? [:]
		}

		/* Collect every oauth_* parameter needs to be included in the signature.
			These values need to be encoded into a single string which will be used later on. The process to build the string
			is very specific:
				Percent encode every key and value that will be signed.
				Sort the list of parameters alphabetically [1] by encoded key [2].

				For each key/value pair:
					Append the encoded key to the output string.
					Append the ‘=’ character to the output string.
					Append the encoded value to the output string.
				If there are more key/value pairs remaining, append a ‘&’ character to the output string.
		*/
		let oathParams: [String:String] = queryParams.merging(["include_entities": "true", "oauth_consumer_key": consumerKey,
			"oauth_nonce": nonce, "oauth_signature_method": "HMAC-SHA1", "oauth_timestamp": timestamp,	// "oauth_token": token,
			"oauth_version": "1.0"]) { (current, _) in current }
		let encodedParams = oathParams.compactMapValues { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
		let sortedParams = encodedParams.sorted { (arg0, arg1) -> Bool in arg0.key < arg1.key }
		let parameterString = sortedParams.reduce("") { (resultSoFar, param) -> String in
			guard resultSoFar != "" else {
				return "\(param.key)=\(param.value)"
			}
			return "\(resultSoFar)&\(param.key)=\(param.value)"
		}

		/*
			Creating the signature base string
			The three values collected so far must be joined to make a single string, from which the signature will be generated.
			This is called the signature base string by the OAuth specification.

			To encode the HTTP method, base URL, and parameter string into a single string:
				Convert the HTTP Method to uppercase and set the output string equal to this value.
				Append the ‘&’ character to the output string.

				Percent encode the URL and append it to the output string.
				Append the ‘&’ character to the output string.

				Percent encode the parameter string and append it to the output string.

				This will produce the following:
				Signature base string
				POST&https%3A%2F%2Fapi.twitter.com%2F1.1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521
				Make sure to percent encode the parameter string! The signature base string should contain exactly 2 ampersand ‘&’ characters. The percent ‘%’ characters in the parameter string should be encoded as %25 in the signature base string.
		*/

		// https://developer.twitter.com/en/docs/basics/authentication/guides/percent-encoding-parameters.html
		let allowedCharacters = CharacterSet.letters.union(CharacterSet.decimalDigits).union(CharacterSet(charactersIn: "-._~"))

		let signature = method.uppercased() + "&" +
			baseUrl.addingPercentEncoding(withAllowedCharacters: allowedCharacters)! + "&" +
			parameterString.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
//print(#function + "signature == \(signature)")
		return signature
	}
}

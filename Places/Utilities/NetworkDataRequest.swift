//
//	NetworkDataRequest.swift
//	Places Near
//
//	Created by Michael Valentiner on 3/15/19.
//	Copyright © 2019 Michael Valentiner. All rights reserved.
//
//	Inspired by http://matteomanferdini.com/network-requests-rest-apis-ios-swift/
//

import UIKit

/// Error types for DataRequestResult
enum DataRequestError: Error {
	case badURLError
	case badURLRequestError
	case decodeDataError
	case encodeDataError
	case httpStatusError(Int)
	case nilDataError
	case notAuthenticatedError
	case sessionDataTaskError(Error)

	internal init(error: Error) {
		self = .sessionDataTaskError(error)
	}

	internal init(httpStatus: Int) {
		self = .httpStatusError(httpStatus)
	}
}

typealias DataRequestResult = Result<Data, DataRequestError>

/// UnauthenticatedDataRequest - http request to request data
protocol UnauthenticatedDataRequest: class { 	// TODO: why : class?
	// Define the endpoint to call.
	var endpointURL: String { get }
	// Request the data.
	func load(onCompletion: @escaping (DataRequestResult) -> Void)

	// Extension point for subtypes
	func makeRequest(for url: URL) -> URLRequest

	func shouldContinue(withHTTPStatusCode statusCode : Int) -> Bool
}

extension UnauthenticatedDataRequest {
	internal func makeRequest(for url: URL) -> URLRequest {
		return URLRequest(url: url)
	}

	internal func load(onCompletion: @escaping (DataRequestResult) -> Void) {
        _load(onCompletion: onCompletion)
	}

	internal func _load(onCompletion: @escaping (DataRequestResult) -> Void) {
        guard let url = URL(string: endpointURL) else {
			onCompletion(DataRequestResult.failure(.badURLError))
			return
        }
		let request = makeRequest(for: url)
		sendRequest(request, onCompletion: onCompletion)
	}

	private func sendRequest(_ request: URLRequest, onCompletion: @escaping (DataRequestResult) -> Void) {
		// Issue the request
		let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
		let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
			// Make sure we have a HTTPURLResponse
			guard let httpResponse = response as? HTTPURLResponse else {
				onCompletion(DataRequestResult.failure(.badURLRequestError))
				return
			}

			// Handle any error
			if let error = error {
				onCompletion(DataRequestResult.failure(.sessionDataTaskError(error)))
				return
			}

			// Ensure we got an acceptable http status
			let statusCode = httpResponse.statusCode
			guard self.shouldContinue(withHTTPStatusCode : statusCode) == true else {
                onCompletion(DataRequestResult.failure(.httpStatusError(statusCode)))
 				return
            }

			// Ensure we received data
			guard let data = data else {
				onCompletion(DataRequestResult.failure(.nilDataError))
				return
			}

			onCompletion(DataRequestResult.success(data))
		})
		task.resume()
	}

	internal func shouldContinue(withHTTPStatusCode statusCode : Int) -> Bool {
		guard statusCode < 300 else {
			return false
		}
		return true
	}
}

typealias DecodableRequestResult<RequestedDataType> = Result<RequestedDataType, DataRequestError>

/// UnauthenticatedDataRequest - http request to request json of associated type <RequestedDataType> and return objects of <RequestedDataType>
protocol UnauthenticatedDecodableRequest: UnauthenticatedDataRequest {
	// Define the type of data being requested.
	associatedtype RequestedDataType: Decodable
}

extension UnauthenticatedDecodableRequest {
	internal func load(onCompletion: @escaping (DecodableRequestResult<RequestedDataType>) -> Void) {
		_load { (dataRequestResult) in
			switch dataRequestResult {
			case .failure(let error):
				onCompletion(DecodableRequestResult<RequestedDataType>.failure(error))
				return
			case .success(let data):
				// Decode the data
				guard let decodedData = self.decode(data) else {
					onCompletion(DecodableRequestResult<RequestedDataType>.failure(.decodeDataError))
					return
				}
				// Success
				onCompletion(DecodableRequestResult<RequestedDataType>.success(decodedData))
			}
		}
	}

	internal func decode(_ data: Data) -> RequestedDataType? {
		do {
			let decodedData = try JSONDecoder().decode(RequestedDataType.self, from: data) // Decoding our data
			return decodedData
		}
		catch {
			return nil
		}
	}
}

/// UnauthenticatedJSONRequest - http request to request generic json data of associated type JSON
protocol UnauthenticatedJSONRequest: UnauthenticatedDecodableRequest where RequestedDataType == JSON {
}

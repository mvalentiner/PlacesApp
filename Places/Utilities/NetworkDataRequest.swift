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

typealias DecodableRequestResult<RequestedDataType> = Result<RequestedDataType, DataRequestError>

/// UnauthenticatedDataRequest - generic http request to request json data of associated type <RequestedDataType>
protocol UnauthenticatedDecodableRequest: class {
	// 1) Define the type of data being requested.
	associatedtype RequestedDataType: Decodable
	// 2) Define the endpoint to call.
	var endpointURL: String { get }
	// 3) Request the data.
	func load(onCompletion: @escaping (DecodableRequestResult<RequestedDataType>) -> Void)

	// Extension point
	func makeRequest(for url: URL) -> URLRequest
}

extension UnauthenticatedDecodableRequest {
	internal func load(onCompletion: @escaping (DecodableRequestResult<RequestedDataType>) -> Void) {
        guard let url = URL(string: endpointURL) else {
            fatalError(#function + "Could not make url from \(endpointURL)")
        }
		let request = makeRequest(for: url)
		sendRequest(request, onCompletion: onCompletion)
	}

	internal func makeRequest(for url: URL) -> URLRequest {
		return URLRequest(url: url)
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

	internal func sendRequest(_ request: URLRequest, onCompletion: @escaping (DecodableRequestResult<RequestedDataType>) -> Void) {
		// Issue the request
		let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
		let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
			// Make sure we have a HTTPURLResponse
			guard let httpResponse = response as? HTTPURLResponse else {
				onCompletion(DecodableRequestResult<RequestedDataType>.failure(.badURLRequestError))
				return
			}

			// Handle any error
			if let error = error {
				onCompletion(DecodableRequestResult<RequestedDataType>.failure(.sessionDataTaskError(error)))
				return
			}

			// Ensure we got an acceptable http status
			let statusCode = httpResponse.statusCode
			guard self.shouldContinue(withHTTPStatusCode : statusCode) == true else {
                onCompletion(DecodableRequestResult<RequestedDataType>.failure(.httpStatusError(statusCode)))
 				return
            }

			// Ensure we received data
			guard let data = data else {
				onCompletion(DecodableRequestResult<RequestedDataType>.failure(.nilDataError))
				return
			}

			// Decode the data
            guard let decodedData = self.decode(data) else {
				onCompletion(DecodableRequestResult<RequestedDataType>.failure(.decodeDataError))
				return
			}

			// Success
			onCompletion(DecodableRequestResult<RequestedDataType>.success(decodedData))
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

/// UnauthenticatedJSONRequest - http request to request generic json data of associated type JSON
protocol UnauthenticatedJSONRequest: UnauthenticatedDecodableRequest where RequestedDataType == JSON {
}

typealias DataRequestResult = Result<Data, DataRequestError>

/// UnauthenticatedDownloadRequest - http request to request download data
protocol UnauthenticatedDataRequest: class {
	// Define the endpoint to call.
	var endpointURL: String { get }
	// Request the data.
	func load(onCompletion: @escaping (DataRequestResult) -> Void)

	// Specify the save to location.
	var saveLocation: URL { get }

	// Extension point
	func makeRequest(for url: URL) -> URLRequest
}

extension UnauthenticatedDataRequest {
	internal func load(onCompletion: @escaping (DataRequestResult) -> Void) {
        guard let url = URL(string: endpointURL) else {
            fatalError(#function + "Could not make url from \(endpointURL)")
        }
		let request = makeRequest(for: url)
		sendRequest(request, onCompletion: onCompletion)
	}

	var saveLocation: URL {
		get {
			return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		}
	}

	internal func makeRequest(for url: URL) -> URLRequest {
		return URLRequest(url: url)
	}

	internal func sendRequest(_ request: URLRequest, onCompletion: @escaping (DataRequestResult) -> Void) {
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

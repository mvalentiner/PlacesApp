//
//  URLRoutingService.swift
//  Places
//
//  Created by Michael Valentiner on 10/10/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation
import UIKit

private struct URLRoutingServiceName {
	static let serviceName = "URLRoutingService"
}

extension ServiceRegistryImplementation {
	var urlRoutingService: URLRoutingService {
		get {
			return serviceWith(name: URLRoutingServiceName.serviceName) as! URLRoutingService	// Intentional force unwrapping
		}
	}
}

//* Signature of a custom url handling function. The return value indicates whether handler successfully handled the operation.
typealias CustomURLHandler = (_: URL, _: String, _: Dictionary<String, String>) -> Bool
typealias CustomURLOperation = String

protocol URLRoutingService: SOAService {
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
	mutating func add(handler: @escaping CustomURLHandler, for handlerName: CustomURLOperation)
	var routingTable: Dictionary<CustomURLOperation, CustomURLHandler> { get set }
}

extension URLRoutingService {
	var serviceName: String {
		get {
			return URLRoutingServiceName.serviceName
		}
	}

	mutating func add(handler: @escaping CustomURLHandler, for operation: CustomURLOperation) {
		routingTable[operation] = handler
	}
}

//* URLRoutingService implements custom url handling.
//	RFC 3986 URL format: scheme:[//[user[:password]@]host[:port]][/path][?query][#fragment]
//	The format of our custom url is: <our_app_custom_scheme>://<operation_handler_name>/<operation>[?name=value&...], where
//		host == <our_app_custom_scheme>
//		operation_handler == <first path component>
//		operation[?parameters] == <remainder of path>
internal class URLRoutingServiceImplementation: URLRoutingService {
	
	// Register the service as a lazy service.
	static func register(using appPropertiesService: AppPropertiesService) {
		ServiceRegistry.add(service: SOALazyService(serviceName: URLRoutingServiceName.serviceName,
			serviceGetter: { URLRoutingServiceImplementation(using: appPropertiesService) }))
	}

	private let appPropertiesService: AppPropertiesService

	init(using appPropertiesService: AppPropertiesService) {
    	self.appPropertiesService = appPropertiesService
	}

	internal var routingTable: Dictionary<CustomURLOperation, CustomURLHandler> = [:]

	// This function takes a custom url and executes the action associated with the url.
	internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		// Sanity check: make sure this url's scheme is a scheme we support.
		guard let scheme = url.scheme, appPropertiesService.appCustomURLSchemes.contains(scheme) else {
			// Missing or unknown scheme.
			return false
		}
		
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			// Mal-formed url
			return false
		}
		
		guard let handlerName = components.host else {
			// Mal-formed url
			return false
		}

		let path = components.path.dropFirst()	// drop leading "/"

		let operation: String
		if let firstSlash = path.firstIndex(of: "/") {
			operation = String(components.path.prefix(upTo: firstSlash))
		} else {
			operation = String(path)
		}

		// Parse the path into a parameter array.
		let parameters = components.queryItems?.reduce(into: [:], { (accumultingResult, queryItem) in
			accumultingResult[queryItem.name] = queryItem.value
		})

		if let action = routingTable[handlerName] {
			return action(url, operation, parameters ?? [:])
		}

		return false
	}
}
// helioplaces://twitterservice/login/success

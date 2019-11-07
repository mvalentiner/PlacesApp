//
//  ReachabilityService.swift
//
//  Created by Michael Valentiner on 3/12/19.
//  Copyright © 2019 Heliotropix. All rights reserved.
//

import SystemConfiguration
import Reachability

fileprivate struct ReachabilityServiceName {
	static let name = "ReachabilityService"
}

extension ServiceRegistryImplementation {
	var reachabilityService: ReachabilityService {
		get {
			return serviceWith(name: ReachabilityServiceName.name) as! ReachabilityService
		}
	}
}

protocol ReachabilityService: SOAService {
	var isReachable: Bool { get }
	var reachability: Reachability { get }

	func setReachableHandler(handler: @escaping (Reachability)-> Void)
	func startMonitoring()
	func stopMonitoring()
}

extension ReachabilityService {
	var serviceName: String {
		get {
			return ReachabilityServiceName.name
		}
	}

	var isReachable: Bool {
		get {
			return reachability.connection != .unavailable
		}
	}
	
	func setReachableHandler(handler: @escaping (Reachability)-> Void){
		reachability.whenReachable = handler
	}

	func startMonitoring() {
		(try? reachability.startNotifier()) ?? print(#function + "Reachability monitoring failed to start.")
	}

	func stopMonitoring() {
		reachability.stopNotifier()
	}
}

class ReachabilityServiceImplementation: ReachabilityService {
	static func register() {
//		ServiceRegistry.add(service: ReachabilityServiceImplementation())
		ServiceRegistry.add(service: SOALazyService(serviceName: ReachabilityServiceName.name) { ReachabilityServiceImplementation() })
	}

	internal let reachability: Reachability = {
		let googlePublicDNS = "8.8.8.8"	//"www.google.com"
		do {
			return try Reachability(hostname: googlePublicDNS)
		} catch {
			fatalError()
		}
	}()
}

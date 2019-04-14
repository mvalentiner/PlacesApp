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

extension ServiceRegistry {
	var reachabilityService : ReachabilityService {
		get {
			return serviceWith(name: ReachabilityServiceName.name) as! ReachabilityService
		}
	}
}

protocol ReachabilityService : Service {
	var isReachable: Bool { get }
	var reachability : Reachability { get }

	func setReachableHandler(handler : @escaping (Reachability)-> Void)
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
			return reachability.connection != .none
		}
	}
	
	func setReachableHandler(handler : @escaping (Reachability)-> Void){
		reachability.whenReachable = handler
	}

	func startMonitoring() {
		(try? reachability.startNotifier()) ?? print(#function + "Reachability monitoring failed to start.")
	}

	func stopMonitoring() {
		reachability.stopNotifier()
	}
}

class ReachabilityServiceImplementation : ReachabilityService {
	static func register() {
		SR.add(service: ReachabilityServiceImplementation())
	}

	internal let reachability : Reachability = {
		let googlePublicDNS = "www.google.com"	//"8.8.8.8"
		return Reachability(hostname: googlePublicDNS)!	// Intentional forced unwrap
	}()
}

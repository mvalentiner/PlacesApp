//
//  AppDelegate.swift
//  Places
//
//  Created by Michael Valentiner on 4/1/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	// Even though serviceRegistry is not referenced in this file, this declaration causes ServiceRegistry to be instantiated
	// and services to be registered prior to application(_ application:, didFinishLaunchingWithOptions:) being called.
	private let serviceRegistry : ServiceRegistryImplementation = {
		AppPropertiesServiceImplementation.register()
		PlacesServiceImplementation.register(placeSources: [InterestingnessPlaceSource()])
		ReachabilityServiceImplementation.register()
		return ServiceRegistry
	}()

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		return true
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		ServiceRegistry.reachabilityService.startMonitoring()
	}

	func applicationWillResignActive(_ application: UIApplication) {
		ServiceRegistry.reachabilityService.stopMonitoring()
	}
}

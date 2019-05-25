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

	// This declaration causes ServiceRegistry to be instantiated
	// and services to be registered prior to application(_ application:, didFinishLaunchingWithOptions:) being called.
	private let serviceRegistry : ServiceRegistryImplementation = {
		AppPropertiesServiceImplementation.register()
		PlacesServiceImplementation.register(placeSources: [InterestingnessPlaceSource()])
		ReachabilityServiceImplementation.register()
		return ServiceRegistry
	}()

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		let rootViewController = UIViewController()
		MainCoordinator.register(rootController: rootViewController)
		let mainViewController = MainViewController.instantiate()
		serviceRegistry.mainCoordinator.start(with: mainViewController)

		// create a basic UIWindow and activate it
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = mainViewController
		window?.makeKeyAndVisible()

		return true
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		serviceRegistry.reachabilityService.startMonitoring()
	}

	func applicationWillResignActive(_ application: UIApplication) {
		serviceRegistry.reachabilityService.stopMonitoring()
	}
}

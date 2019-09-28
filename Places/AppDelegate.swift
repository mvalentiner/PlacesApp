//
//  AppDelegate.swift
//  Places
//
//  Created by Michael Valentiner on 4/1/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import SwifteriOS
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	// This declaration causes ServiceRegistry to be instantiated
	// and services to be registered prior to application(_ application:, didFinishLaunchingWithOptions:) being called.
	private let serviceRegistry: ServiceRegistryImplementation = {
		AppPropertiesServiceImplementation.register()
		PlacesServiceImplementation.register(using: [InterestingnessPlaceSource()])
		ReachabilityServiceImplementation.register()
		return ServiceRegistry
	}()

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Instantiate the MainCoordinator as an SOA Service and give it it's rootViewController.
		let rootViewController = UINavigationController()
		MainCoordinator.register(using: rootViewController)
		ServiceRegistry.mainCoordinator.presentMainViewController()

		// We don't instantiate the default view controller from Main.Storyboard, so create a UIWindow and activate it.
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = rootViewController
		window?.makeKeyAndVisible()

		return true
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		serviceRegistry.reachabilityService.startMonitoring()
	}

	func applicationWillResignActive(_ application: UIApplication) {
		serviceRegistry.reachabilityService.stopMonitoring()
	}

	func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		return Swifter.handleOpenURL(url, callbackURL: url)
	}
}

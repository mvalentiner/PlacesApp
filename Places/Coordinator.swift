//
//  Coordinator.swift
//  Places
//
//  Created by Michael Valentiner on 5/24/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//
//	https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

import UIKit

private struct MainCoordinatorServiceName {
	static let serviceName = "MainCoordinatorService"
}

extension ServiceRegistryImplementation {
	var mainCoordinator : MainCoordinatorService {
		get {
			return serviceWith(name: MainCoordinatorServiceName.serviceName) as! MainCoordinatorService	// Intentional force unwrapping
		}
	}
}

protocol MainCoordinatorService : SOAService {
	var rootController: UIViewController { get }

	func start(with viewController: UIViewController)
	
	func navigateToInfoScreen()
	func navigateToPlaceDetailsScreen(forPlace: Place)
}

extension MainCoordinatorService {
	var serviceName : String {
		get {
			return MainCoordinatorServiceName.serviceName
		}
	}

	func start(with viewController: UIViewController) {
		rootController.present(viewController, animated: true)		//pushViewController(viewController, animated: false)
	}

	func navigateToInfoScreen() {
	}

	func navigateToPlaceDetailsScreen(forPlace: Place) {
	}
}

internal class MainCoordinator: MainCoordinatorService {
	
	static func register(rootController: UIViewController) {
//		ServiceRegistry.add(service: SOALazyService(serviceName: MainCoordinatorServiceName.serviceName,
//			serviceGetter: { MainCoordinator(rootController: rootController) }))
		MainCoordinator(rootController: rootController).register()
	}

	var rootController: UIViewController

	init(rootController: UIViewController) {
		self.rootController = rootController
	}
}

//
//  Coordinator.swift
//  Places
//
//  Created by Michael Valentiner on 5/24/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//
//	Inspired by https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

import CoreLocation
import UIKit

protocol Coordinator {
	var rootController: UINavigationController { get }

	func present(_ viewController: UIViewController, animated: Bool)
	
	func popToRootController(animated: Bool)
}

extension Coordinator {
	func present(_ viewController: UIViewController, animated: Bool = true) {
		rootController.pushViewController(viewController, animated: animated)
	}
	
	func popToRootController(animated: Bool = true) {
		rootController.popToRootViewController(animated: animated)
	}
}

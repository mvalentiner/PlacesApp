//
//  MainCoordinator.swift
//  Places
//
//  Created by Michael Valentiner on 6/3/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//
//	Inspired by https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

import CoreLocation
import SwifteriOS
import SwiftUI
import UIKit

private struct MainCoordinatorServiceName {
	static let serviceName = "MainCoordinatorService"
}

extension ServiceRegistryImplementation {
	var mainCoordinator: MainCoordinatorService {
		get {
			return serviceWith(name: MainCoordinatorServiceName.serviceName) as! MainCoordinatorService	// Intentional force unwrapping
		}
	}
}

protocol MainCoordinatorService: Coordinator, SOAService {
	func presentMainViewController()
	func navigateToInfoScreen()
	func navigateToPlaceDetailsScreen(for place: Place)
}

internal class MainCoordinator: MainCoordinatorService {
	var serviceName: String = MainCoordinatorServiceName.serviceName
	
	static func register(using rootController: UINavigationController) {
		MainCoordinator(rootController: rootController).register()
	}

	var rootController: UINavigationController

	init(rootController: UINavigationController) {
		self.rootController = rootController
	}

	internal func presentMainViewController() {
		present(MainViewController.instantiate())
	}

	internal func navigateToInfoScreen() {
		let hostingController = UIHostingController(rootView: SettingsScreenView(with: self))
		present(hostingController)
	}

	private let placeDetailsViewControllerRegistry: [PlaceSourceUID: (Place) -> UIViewController] = [
		InterestingnessPlaceSource.uid : { place in
			guard let placeSource = ServiceRegistry.placesService.placeSources[InterestingnessPlaceSource.uid] as? InterestingnessPlaceSource else {
				fatalError("Programmer Error: the app is not configured for InterestingnessPlaceSource")
			}
			return FlickrPlaceDetailsViewController(for: place, with: placeSource)
		}
	]

	internal func navigateToPlaceDetailsScreen(for place: Place) {
		guard let makePlaceDetailsViewController = placeDetailsViewControllerRegistry[place.uid.placeSourceUID] else {
			fatalError("ERROR, no placeDetailsViewController registered for placeSourceUID = \(place.uid.placeSourceUID)")
		}
		let placeDetailsViewController = makePlaceDetailsViewController(place)
		present(placeDetailsViewController)
	}
}

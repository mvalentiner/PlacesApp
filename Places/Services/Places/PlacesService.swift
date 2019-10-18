//
//  PlacesService.swift
//  Places
//
//  Created by Michael Valentiner on 3/20/19.
//  Copyright © 2019 Michael Valentiner. All rights reserved.
//

import UIKit

/// PlacesService maintains a list of PlaceSources.
///		When places are requested, getPlaces(forRegion:) delegates to all active PlaceSources to return places from their source.


/// PlacesServiceName
fileprivate struct PlacesServiceName {
	static let serviceName = "PlacesService"
}

/// ServiceRegistryImplementation extension to provide convenience property for accessing the service.
extension ServiceRegistryImplementation {
	var placesService: PlacesService {
		get {
			return serviceWith(name: PlacesServiceName.serviceName) as! PlacesService	// Intentional force unwrapping
		}
	}
}

/// PlacesService Interface
protocol PlacesService: SOAService {
	func getPlaces(forRegion: CoordinateRect, onCompletionForEach: @escaping (Result<Place?, Error>) -> Void)
	func getPlaceDetail(for: Place, completionHandler: @escaping (Result<PlaceDetail?, Error>) -> Void)

	var placeSources: [PlaceSourceUId: PlaceSource] { get }
	func isPlaceSourceActive(forId: PlaceSourceUId) -> Bool
}

/// PlacesService Service protocol requirement
extension PlacesService {
	var serviceName: String {
		get {
			return PlacesServiceName.serviceName
		}
	}
}

/// PlacesService default implementation
extension PlacesService {
	func getPlaces(forRegion region: CoordinateRect, onCompletionForEach: @escaping (Result<Place?, Error>) -> Void) {
		placeSources.values.forEach { (placeSource) in
			guard isPlaceSourceActive(forId: placeSource.placeSourceUId) else {
				onCompletionForEach(Result.success(nil))
				return
			}

			placeSource.getPlaces(forRegion: region) { (result) in
				onCompletionForEach(result)
			}
		}
	}

	func getPlaceDetail(for place: Place, completionHandler: @escaping (Result<PlaceDetail?, Error>) -> Void) {
		let placeSourceUID = place.uid.placeSourceUId
		guard let placeSource = placeSources[placeSourceUID] else {
			fatalError("Error: PlacesServiceImplementation misconfiguration. No PlaceSource found for \(placeSourceUID)")
		}
		placeSource.getPlaceDetail(for: place) { (result) in
			completionHandler(result)
		}
	}
}

/// PlacesServiceImplementation
internal class PlacesServiceImplementation: PlacesService {
	static func register(using placeSources: [PlaceSource], isActiveTable: [PlaceSourceUId : () -> Bool]) {
		ServiceRegistry.add(service: PlacesServiceImplementation(placeSources: placeSources, isActiveTable: isActiveTable))
	}
	
	internal var placeSources: [PlaceSourceUId: PlaceSource] = [:]

	private var isActiveTable: [PlaceSourceUId : () -> Bool]

	func isPlaceSourceActive(forId id: PlaceSourceUId) -> Bool {
		guard let isActive = isActiveTable[id] else {
			fatalError("Unknown PlaceSourceId == \(id)")
		}
		return isActive()
	}

	/*
		A PlacesServiceImplementation is initiialized with an array of PlaceSources and a Dictionary associating a PlaceSourceId
		with a function whose value indicates whether the PlaceSource is active or not.
	*/
	init(placeSources: [PlaceSource], isActiveTable: [PlaceSourceUId : () -> Bool]) {
		self.isActiveTable = isActiveTable
		placeSources.forEach { (placeSource) in
			self.placeSources[placeSource.placeSourceUId] = placeSource
		}
	}
}

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
	var placesService : PlacesService {
		get {
			return serviceWith(name: PlacesServiceName.serviceName) as! PlacesService	// Intentional force unwrapping
		}
	}
}

/// PlacesService Interface
protocol PlacesService : SOAService {
	func getPlaces(forRegion: CoordinateRect, onCompletionForEach: @escaping (Result<Place?, Error>) -> Void)
	func getPlaceDetail(forUID: PlaceUID, completionHandler: @escaping (Result<PlaceDetail?, Error>) -> Void)

	var placeSources : [PlaceSourceUID : PlaceSource] { get }
}

/// PlacesService Service protocol requirement
extension PlacesService {
	var serviceName : String {
		get {
			return PlacesServiceName.serviceName
		}
	}
}

/// PlacesService default implementation
extension PlacesService {
	func getPlaces(forRegion region: CoordinateRect, onCompletionForEach: @escaping (Result<Place?, Error>) -> Void) {
		placeSources.values.forEach { (placeSource) in
			placeSource.getPlaces(forRegion: region) { (result) in
				onCompletionForEach(result)
			}
		}
	}

	func getPlaceDetail(forUID placeUID: PlaceUID, completionHandler : @escaping (Result<PlaceDetail?, Error>) -> Void) {
		let placeSourceUID = placeUID.placeSourceUID
		guard let placeSource = placeSources[placeSourceUID] else {
			fatalError("Error: PlacesServiceImplementation misconfiguration. No PlaceSource found for \(placeSourceUID)")
		}
		placeSource.getPlaceDetail(forUID: placeUID) { (result) in
			completionHandler(result)
		}
	}
}

/// PlacesServiceImplementation
internal class PlacesServiceImplementation : PlacesService {
	static func register(placeSources : [PlaceSource]) {
		ServiceRegistry.add(service: PlacesServiceImplementation(placeSources: placeSources))
	}
	
	internal var placeSources : [PlaceSourceUID : PlaceSource] = [:]

	init(placeSources: [PlaceSource]) {
		placeSources.forEach { (placeSource) in
			self.placeSources[placeSource.placeSourceUID] = placeSource
		}
	}
}

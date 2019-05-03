//
//  Places.swift
//  Places
//
//  Created by Michael Valentiner on 3/20/19.
//  Copyright © 2019 Michael Valentiner. All rights reserved.
//

import MapKit
import PromiseKit

struct PlaceUID {
	let placeSourceUID : PlaceSourceUID
	let nativePlaceId : String
}

struct Place {
	let uid : PlaceUID
	let location : CLLocationCoordinate2D
	let title : String
	let description : String?
	let preview : UIImage?
}

struct PlaceDetail {
	let place : Place
	let detail : String?
	let images : [UIImage]?
}

typealias PlaceSourceUID = String

protocol PlaceSource {
	var placeSourceUID : PlaceSourceUID { get }
		// placeSourceUID is used internally to the PlacesService classes and not exposed through the PlaceService interface.

	var placeSourceName : String  { get }
		// placeSourceName is a user facing name for the PlaceSource.

//	func getPlaces(forRegion : CoordinateRect) -> Promise<[Place]>
	func getPlaces(forRegion : CoordinateRect, onCompletionForEach : @escaping (Place) -> Void)
		// Given a region, get the places from PlaceSource located in the region.

	func getPlaceDetail(forUID : PlaceUID, completionHandler : @escaping (PlaceDetail?) -> Void)
		// Given a PlaceUID, get its PlaceDetails.
}

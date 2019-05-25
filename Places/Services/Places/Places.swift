//
//  Places.swift
//  Places
//
//  Created by Michael Valentiner on 3/20/19.
//  Copyright © 2019 Michael Valentiner. All rights reserved.
//

import MapKit

typealias PlaceSourceUID = String

struct PlaceUID : Hashable {
	let placeSourceUID : PlaceSourceUID
	let nativePlaceId : String
}

struct Place : Hashable {
	let uid : PlaceUID
	let location : CLLocationCoordinate2D
	let title : String
	let description : String?
	let preview : UIImage?

	static func == (lhs: Place, rhs: Place) -> Bool {
		return lhs.uid == rhs.uid
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(uid)
	}
}

struct PlaceDetail {
	let place : Place
	let detail : String?
	let images : [UIImage]?
}


protocol PlaceSource {
	var placeSourceUID : PlaceSourceUID { get }
		// placeSourceUID is used internally to the PlacesService classes and not exposed through the PlaceService interface.

	var placeSourceName : String  { get }
		// placeSourceName is a user facing name for the PlaceSource.

	func getPlaces(forRegion : CoordinateRect, onCompletionForEach : @escaping (Result<Place?, Error>) -> Void)
		// Given a region, get the places from PlaceSource located in the region.

	func getPlaceDetail(forUID : PlaceUID, completionHandler : @escaping (Result<PlaceDetail?, Error>) -> Void)
		// Given a PlaceUID, get its PlaceDetails.
}

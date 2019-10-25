//
//  Places.swift
//  Places
//
//  Created by Michael Valentiner on 3/20/19.
//  Copyright © 2019 Michael Valentiner. All rights reserved.
//

import MapKit

typealias PlaceSourceUId = String

struct PlaceUId: Hashable {
	let placeSourceUId: PlaceSourceUId
	let nativePlaceId: String
}

class Place: Hashable {
	let uid: PlaceUId
	let location: CLLocationCoordinate2D
	let title: String
	let description: String?
	let preview: UIImage?

	init(uid: PlaceUId, location: CLLocationCoordinate2D, title: String, description: String? = nil, preview: UIImage? = nil) {
		self.uid = uid
		self.location = location
		self.title = title
		self.description = description
		self.preview = preview
	}

	static func ==(lhs: Place, rhs: Place) -> Bool {
		return lhs.uid == rhs.uid
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(uid)
	}
}

struct PlaceDetail {
	let uid: PlaceUId
	let detail: String?
	let images: [UIImage]?
}

protocol PlaceSource {
	var placeSourceUId: PlaceSourceUId { get }
		// placeSourceUId is used internally to the PlacesService classes and not exposed through the PlaceService interface.

	var placeSourceName: String  { get }
		// placeSourceName is a user facing name for the PlaceSource.

	func isActive() -> Bool

	func getPlaces(forRegion: CoordinateRect, onCompletionForEach: @escaping (Result<Place?, Error>) -> Void)
		// Given a region, get the places from PlaceSource located in the region.

	func getPlaceDetail(for: Place, completionHandler: @escaping (Result<PlaceDetail?, Error>) -> Void)
		// Given a PlaceUId, get its PlaceDetails.
}

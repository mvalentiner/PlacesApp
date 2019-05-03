//
//  InterestingnessPlaceSource.swift
//  Places
//
//  Created by Michael Valentiner on 4/30/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation

struct InterestingnessPlaceSource : PlaceSource {
	var placeSourceUID : PlaceSourceUID {
		get {
			return "Interestingness"
		}
	}

	var placeSourceName : String {
		get {
			return "Interestingness"
		}
	}

	/// Given a region, get the places from PlaceSource located in the region.
	func getPlaces(forRegion region: CoordinateRect, onCompletionForEach : @escaping (Place) -> Void) {
		
		Flickr().requestPhotoAnnotations(forSearchText: "", withLocationBottomLeft: region.bottomLeft, andLocationTopRight: region.topRight,
			maximumNumberOfPhotos: 100, page: 0, completionHandler: { flickrPhotoInfo in
			guard let flickrPhotoInfo = flickrPhotoInfo else {
				return
			}
			let placeUId = PlaceUID(placeSourceUID: self.placeSourceUID, nativePlaceId: flickrPhotoInfo.photoURLString)
			let place = Place(uid: placeUId, location: flickrPhotoInfo.coordinate, title: flickrPhotoInfo.title, description: "", preview: flickrPhotoInfo.thumbnailImage)
			onCompletionForEach(place)
		})
	}

	/// Given a PlaceUID, get its PlaceDetails.
	func getPlaceDetail(forUID : PlaceUID, completionHandler : (PlaceDetail?) -> Void) {
	}
}

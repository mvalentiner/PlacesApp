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
	func getPlaces(forRegion region: CoordinateRect, onCompletionForEach : @escaping (Result<Place, Error>) -> Void) {
		
		Flickr().requestPhotoAnnotations(forSearchText: "", withLocationBottomLeft: region.bottomLeft, andLocationTopRight: region.topRight,
				maximumNumberOfPhotos: 100, page: 0, completionHandler: { result in
			guard let flickrPhotoInfo = try? result.get() else {
//				onCompletionForEach(Result(failure: result.error))
				return
			}
			let placeUId = PlaceUID(placeSourceUID: self.placeSourceUID, nativePlaceId: flickrPhotoInfo.photoURLString)
			let place = Place(uid: placeUId, location: flickrPhotoInfo.coordinate, title: flickrPhotoInfo.title, description: "", preview: flickrPhotoInfo.thumbnailImage)
			onCompletionForEach(Result(success: place))
		})
	}

	/// Given a PlaceUID, get its PlaceDetails.
	func getPlaceDetail(forUID : PlaceUID, completionHandler : (Result<PlaceDetail, Error>) -> Void) {
	}
}

//
//  InterestingnessPlaceSource.swift
//  Places
//
//  Created by Michael Valentiner on 4/30/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import CoreLocation
import UIKit

struct InterestingnessPlaceSource: PlaceSource {
	static let uid = "INTR"

	// protocol PlaceSource requirements
	let placeSourceUId: PlaceSourceUId = InterestingnessPlaceSource.uid
	let placeSourceName = "Interestingness"

	// "Inject" Dependencies.
	private let flickr = Flickr()

	//TODO: make private
	internal class FlickrPlace: Place {
		var details: PlaceDetail?
		var photoURL: String
		init(uid: PlaceUId, location: CLLocationCoordinate2D, title: String, preview: UIImage? = nil, photoURL: String) {
			self.photoURL = photoURL
			super.init(uid: uid, location: location, title: title, preview: preview)
		}
	}

	/// Given a region, get the places from PlaceSource located in the region.
	func getPlaces(forRegion region: CoordinateRect, onCompletionForEach: @escaping (Result<Place?, Error>) -> Void) {
		self.flickr.requestPhotoAnnotations(forSearchText: "", withLocationBottomLeft: region.bottomLeft, andLocationTopRight: region.topRight,
				maximumNumberOfPhotos: 100, page: 0) { result in
			switch result {
			case .failure(let error):
				onCompletionForEach(.failure(error))
			case .success(let flickrPhotoInfo):
				guard let flickrPhotoInfo = flickrPhotoInfo else {
					onCompletionForEach(.success(nil))
					return
				}
				// TODO:  optimize nativePlaceId
				let placeUId = PlaceUId(placeSourceUId: self.placeSourceUId, nativePlaceId: flickrPhotoInfo.photoURLString)
				let place = FlickrPlace(uid: placeUId, location: flickrPhotoInfo.coordinate, title: flickrPhotoInfo.title,
					preview: flickrPhotoInfo.thumbnailImage, photoURL: flickrPhotoInfo.photoURLString)
				onCompletionForEach(.success(place))
			}
		}
	}

	/// Given a PlaceUId, get its PlaceDetails.
	func getPlaceDetail(for place: Place, completionHandler: @escaping (Result<PlaceDetail?, Error>) -> Void) {
		guard let flickrPlace = place as? FlickrPlace else {
			fatalError("Error: \(#function) called with non-FlickrPlace")
		}
		guard let details = flickrPlace.details else {
			self.flickr.requestPhoto(forURL: flickrPlace.photoURL) { (result) in
				switch result {
				case .failure(let error):
					completionHandler(.failure(error))
				case .success(let image):
					guard let image = image else {
						completionHandler(.success(nil))
						return
					}
					let details = PlaceDetail(uid: flickrPlace.uid, detail: nil, images: [image])
					completionHandler(.success(details))
				}
			}
			return
		}
		completionHandler(.success(details))
	}
}

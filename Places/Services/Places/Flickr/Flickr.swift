//
//  Flickr.swift
//  Photos Here
//
//  Created by Michael on 3/3/15.
//  Copyright (c) 2015 Heliotropix. All rights reserved.
//

import Foundation
import MapKit
import PromiseKit


// FickrAPIKey needs to be defined.

class Flickr {

	private var _searchText = ""
	private var _bottomLeft = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	private var _topRight = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	private var _maximumNumberOfPhotos = 0
	private var _page = 0

	internal func requestPhotoAnnotations(forSearchText searchText: String, withLocationBottomLeft bottomLeft: CLLocationCoordinate2D,
			andLocationTopRight topRight: CLLocationCoordinate2D, maximumNumberOfPhotos: Int, page: Int,
			completionHandler: @escaping (Swift.Result<FlickrPhotoInfo?, Error>) -> Void) {
		_searchText = "-kid -kids -child -children " + searchText
		_bottomLeft = bottomLeft
		_topRight = topRight
		_maximumNumberOfPhotos = maximumNumberOfPhotos
		_page = 0
		let searchURLString = buildSearchStringForLocationBottomLeft(_searchText, bottomLeft: _bottomLeft, topRight: _topRight,
			numberOfPhotos: maximumNumberOfPhotos, page: _page)

		requestPhotoAnnotations(searchURLString, completionHandler: completionHandler)
	}

	class FlickrPhotoSearchRequest : UnauthenticatedJSONRequest {
		internal var endpointURL : String
		init(endpointURL : String) {
			self.endpointURL = endpointURL
		}
	}

	private func requestPhotoAnnotations(_ searchURLString: String, completionHandler: @escaping (Swift.Result<FlickrPhotoInfo?, Error>) -> Void) {
		let dataRequest = FlickrPhotoSearchRequest(endpointURL: searchURLString)
		do {
			_ = try dataRequest.load().done { photoJSON in
				guard let photosValue = photoJSON["photos"], case JSON.object(let photosDict) = photosValue else {
					return
				}
				guard let photoArrayValue = photosDict["photo"], case JSON.array(let photoJSONArray) = photoArrayValue else {
					return
				}
				guard photoJSONArray.isEmpty == false else {
					completionHandler(Swift.Result(success: nil))
					return
				}
				photoJSONArray.forEach({ (photoJSON) in
					guard let id = photoJSON["id"]?.stringValue else {
						return
					}
					guard let latitudeString = photoJSON["latitude"]?.stringValue, let latitude = Double(latitudeString) else {
						return
					}
					guard let longitudeString = photoJSON["longitude"]?.stringValue, let longitude = Double(longitudeString) else {
						return
					}
					guard let title = photoJSON["title"]?.stringValue else {
						return
					}
					guard let photoURLString : String = {
						let photoURLString : String?
						if let urlString = photoJSON["url_k"]?.stringValue {
							photoURLString = urlString
						}
						else if let urlString = photoJSON["url_h"]?.stringValue {
							photoURLString = urlString
						}
						else if let urlString = photoJSON["url_b"]?.stringValue {
							photoURLString = urlString
						}
						else if let urlString = photoJSON["url_c"]?.stringValue {
							photoURLString = urlString
						}
						else if let urlString = photoJSON["url_z"]?.stringValue {
							photoURLString = urlString
						}
						else {
							photoURLString = nil
						}
						return photoURLString
					}() else {
						return
					}
	
					self.requestThumbnail(photoJSON) { thumbnail in
						guard let thumbnail = thumbnail else {
							return
						}
						let photoInfo = FlickrPhotoInfo(id: id, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
								title: title, thumbnailImage: thumbnail, photoURLString: photoURLString, image: nil)
						completionHandler(Swift.Result(success: photoInfo))
					}
				})
			}.catch { error in
				completionHandler(Swift.Result(failure: error))
			}
		} catch(let error) {
			completionHandler(Swift.Result(failure: error))
		}
	}

	func requestNextPage(_ completionHandler: @escaping (Swift.Result<FlickrPhotoInfo?, Error>) -> Void) {
		_page += 1
		let searchURLString = buildSearchStringForLocationBottomLeft(_searchText, bottomLeft: _bottomLeft, topRight: _topRight,
			numberOfPhotos:_maximumNumberOfPhotos, page: _page)
		requestPhotoAnnotations(searchURLString, completionHandler: completionHandler)
	}
/*
s	small square 75x75
q	large square 150x150
t	thumbnail, 100 on longest side
m	small, 240 on longest side
n	small, 320 on longest side
-	medium, 500 on longest side
z	medium 640, 640 on longest side
c	medium 800, 800 on longest side†
b	large, 1024 on longest side*
h	large 1600, 1600 on longest side†
k	large 2048, 2048 on longest side†
o	original image, either a jpg, gif or png, depending on source format
* Before May 25th 2010 large photos only exist for very large original images.

† Medium 800, large 1600, and large 2048 photos only exist after March 1st 2012.

https://api.flickr.com/services/rest/?method=flickr.photos.search
https://api.flickr.com/services/rest/?method=flickr.places.findByLatLon
https://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=<FickrAPIKey>&format=json&
	lat=44.9778&lon=-93.2650&extras=geo,geo_context=2,media=photos,url_s,url_k,url_h,url_b,url_c,url_z

jsonFlickrApi(
{"places":
	{"place":[
		{"place_id":"sTXjQKNTUb9enZi8dg","woeid":"23511858","latitude":"40.748","longitude":"-73.948",
			"place_url":"\/United+States\/New+York\/New+York\/Hunters+Point","place_type":"neighbourhood","place_type_id":"22",
			"timezone":"America\/New_York","name":"Hunters Point, New York, NY, US, United States","woe_name":"Hunters Point"
		}
	],
	"latitude":"40.744111","longitude":"-73.960638","accuracy":"16","total":1
	},"stat":"ok"
})

https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=<FickrAPIKey>&format=json&
	place_id=bxCOPF5QUL_tPkfAag&extras=geo,media=photos,url_s,url_k,url_h,url_b,url_c,url_z&min_taken_date=1426396358

jsonFlickrApi({
"photos":
	{"page":1,"pages":2,"perpage":250,"total":"450",
	"photo":[
		{"id":"32846186445",
		"owner":"44550450@N04",
		"secret":"94065542a",
		"server":"2851",
		"farm":3,
		"title":"March in support of immigrants and refugees",
		"ispublic":1,
		"isfriend":0,
		"isfamily":0,
		"latitude":"44.979788",
		"longitude":"-93.263754",
		"accuracy":"16",
		"context":0,"place_id":"bxCOPF5QUL_tPkfAag",
		"woeid":"12523430",
		"geo_is_family":0,"geo_is_friend":0,"geo_is_contact":0,"geo_is_public":1,
		"url_s":"https:\/\/farm3.staticflickr.com\/2851\/32846186445_94065542a4_m.jpg",
		"height_s":"135",
		"width_s":"240",
		"url_k":"https:\/\/farm3.staticflickr.com\/2851\/32846186445_25fbb88187_k.jpg",
		"height_k":1152,"width_k":"2048",
		"url_h":"https:\/\/farm3.staticflickr.com\/2851\/32846186445_6983df023a_h.jpg",
		"height_h":900,"width_h":"1600",
		"url_c":"https:\/\/farm3.staticflickr.com\/2851\/32846186445_94065542a4_c.jpg",
		"height_c":450,"width_c":"800",
		"url_z":"https:\/\/farm3.staticflickr.com\/2851\/32846186445_94065542a4_z.jpg",
		"height_z":"360",
		"width_z":"640"
		},
	]
	},
	...
"stat":"ok"
})

*/
	private func buildSearchStringForLocationBottomLeft(_ searchText: String, bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D,
		numberOfPhotos: Int, page: Int) -> String {

		let baseURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
		let apiKey = "api_key=\(FickrAPIKey)"
		let format = "format=json"
		let boundingBox = stringWithFormat("bbox=%f,%f,%f,%f", args: bottomLeft.longitude, bottomLeft.latitude, topRight.longitude, topRight.latitude)
		let extras = "extras=geo,media=photos,url_s,url_t,url_q,url_k,url_h,url_b,url_c,url_z&sort=interestingness-desc"
		let noJSONCallback = "nojsoncallback=1"
		let perPage = "per_page=" + String(numberOfPhotos)
		let page = "page=" + String(page)
		let text = "text=" + escapeIllegalJSONCharacters(searchText)

		return stringWithFormat("%@&%@&%@&%@&%@&%@&%@&%@&%@", args: baseURL, apiKey, format, boundingBox, extras, noJSONCallback, perPage, page, text)
	}

	private func escapeIllegalJSONCharacters(_ jsonString: String) -> String {

		let nsString = NSMutableString(string: jsonString)
		let range = NSMakeRange(0, nsString.length)
		nsString.replaceOccurrences(of: " ", with: "%20", options: NSString.CompareOptions.caseInsensitive, range: range)
		nsString.replaceOccurrences(of: "'", with: "\\\'", options: NSString.CompareOptions.caseInsensitive, range: range)
		nsString.replaceOccurrences(of: "\"", with: "\\\"", options: NSString.CompareOptions.caseInsensitive, range: range)
		nsString.replaceOccurrences(of: "/", with: "\\/", options: NSString.CompareOptions.caseInsensitive, range: range)
		nsString.replaceOccurrences(of: "\n", with: "\\n", options: NSString.CompareOptions.caseInsensitive, range: range)
// nsString.replaceOccurrencesOfString("\b", withString: "\\b", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range)
// nsString.replaceOccurrencesOfString("\f", withString: "\\f", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range)
		nsString.replaceOccurrences(of: "\r", with: "\\r", options: NSString.CompareOptions.caseInsensitive, range: range)
		nsString.replaceOccurrences(of: "\t", with: "\\t", options: NSString.CompareOptions.caseInsensitive, range: range)
		return nsString as String
	}

	private func requestThumbnail(_ photoDict: JSON, completionHandler: @escaping (UIImage?) -> Void) {
		guard let thumbnailURL : URL = {
			let thumbnailURLOptionalString : String?
			if let urlString : String = photoDict["url_s"]?.stringValue {
				thumbnailURLOptionalString = urlString
			}
			else if let urlString: String = photoDict["url_t"]?.stringValue {
				thumbnailURLOptionalString = urlString
			}
			else if let urlString: String = photoDict["url_q"]?.stringValue {
				thumbnailURLOptionalString = urlString
			}
			else {
				thumbnailURLOptionalString = nil
			}
			guard let thumbnailURLString = thumbnailURLOptionalString, let thumbnailURL = URL(string:thumbnailURLString) else {
				return nil
			}
			return thumbnailURL
		}() else {
			completionHandler(nil)
			return
		}
		firstly {
			URLSession.shared.dataTask(.promise, with: URLRequest(url: thumbnailURL)).validate()
		}.done { blob, response in
			completionHandler(UIImage(data: blob))
		}.catch { _ in
			completionHandler(nil)
		}
	}

	internal func requestPhoto(forPhotoInfo photoInfo: FlickrPhotoInfo, completionHandler: @escaping (UIImage) -> Void) {
		if let image = photoInfo.image {
			completionHandler(image)
			return
		}

		guard let url = URL(string: photoInfo.photoURLString) else {
			return
		}

		let request = URLRequest(url: url)
		URLSession.shared.dataTask(with: request, completionHandler: { (data, _, _) in
			guard let data = data, let image = UIImage(data: data) else {
				return
			}
			completionHandler(image)
		}).resume()
	}
}

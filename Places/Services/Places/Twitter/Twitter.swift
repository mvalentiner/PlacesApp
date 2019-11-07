//
//  Twitter.swift
//  Places
//
//  Created by Michael Valentiner on 8/27/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import CoreLocation
import SafariServices
import UIKit

struct TwitterInfo {
	let placeId: String
	let coordinate: CLLocationCoordinate2D
	let title: String

	init(from json: JSON) throws {
// TODO: implement correctly
		guard let tweetId = json["tweetId"]?.stringValue,
			let latitude = json["latitude"]?.floatValue,
			let longitude = json["longitude"]?.floatValue,
			let title = json["title"]?.stringValue else {
				throw DataRequestError.decodeDataError
		}
		self.placeId = tweetId
		self.coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
		self.title = title
	}
}

protocol TwitterService: class, SOAService {
	func isLoggedIn() -> Bool
	func loginToTwitter(mainCoordinator: MainCoordinatorService)
	func getTweets(forLocationBottomLeft bottomLeft: CLLocationCoordinate2D, locationTopRight topRight: CLLocationCoordinate2D,
		maximumNumberOfPhotos: Int, page: Int, completionHandler: @escaping (Swift.Result<TwitterInfo, Error>) -> Void)
}

private struct TwitterServiceName {
	static let serviceName = "TwitterService"
}

extension ServiceRegistryImplementation {
	var twitterService: TwitterService {
		get {
			return serviceWith(name: TwitterServiceName.serviceName) as! TwitterService	// Intentional force unwrapping
		}
	}
}

internal class TwitterServiceImplementation: TwitterService {

	init(with urlRoutingService: inout URLRoutingService) {
		urlRoutingService.add(handler: handleAuthorizeSuccess, for: "twitterservice")
	}

	// Persistent twitterCredential
	@UserDefault("twitterCredential", defaultValue: nil) var twitterCredential: SwifterCredential?

	// SOAService protocol requirements
	var serviceName: String {
		get {
			return TwitterServiceName.serviceName
		}
	}

	@discardableResult
	static func register(with urlRoutingService: inout URLRoutingService) -> TwitterServiceImplementation {
		let service = TwitterServiceImplementation(with: &urlRoutingService)
		service.register()
		return service
	}

	// TwitterService protocol requirements
	
	internal func isLoggedIn() -> Bool {
		return self.twitterCredential != nil
	}

	func loginToTwitter(mainCoordinator: MainCoordinatorService) {
		let failureHandler: (Error) -> Void = { error in
			print("Error == \(error.localizedDescription)")
		}
		let callbackUrl = URL(string: "helioplaces://twitterservice/AuthorizeSuccess")!
		let swifterAuth = SwifterAuth(consumerKey: TwitterConsumerAPIKey, consumerSecret: TwitterConsumerAPISecretKey)
		swifterAuth.authorize(withCallback: callbackUrl, presentingFrom: mainCoordinator.rootController.topViewController, forceLogin: false, safariDelegate: nil,
				success: { accessToken, _ in
					self.twitterCredential = swifterAuth.client.credential
//TODO
					let settingsModel = SettingsDataModel()
					settingsModel.twitterIsActive = true
					mainCoordinator.popToRootController()
					mainCoordinator.navigateToInfoScreen()
				},
				failure: failureHandler)
	}
	
	private func handleAuthorizeSuccess(url: URL, operation: String, parameters : Dictionary<String, String>) -> Bool {
		guard operation == "AuthorizeSuccess" else {
			// Unsupported operation.
			// TODO: handle? log? fatal?
			return false
		}

		SwifterAuth.handleOpenURL(url)

		return true
	}

	internal func getTweets(forLocationBottomLeft bottomLeft: CLLocationCoordinate2D, locationTopRight topRight: CLLocationCoordinate2D,
		maximumNumberOfPhotos: Int, page: Int, completionHandler: @escaping (Swift.Result<TwitterInfo, Error>) -> Void) {

		guard let twitterCredential = twitterCredential else {
			// TODO: handle? should never happen?
			return
		}

// TODO: implement correctly
		let bottomLeftLocation = CLLocation(latitude: bottomLeft.latitude, longitude: bottomLeft.longitude)
		let topRightLocation = CLLocation(latitude: topRight.latitude, longitude: topRight.longitude)
		let distance = bottomLeftLocation.distance(from: topRightLocation) / 2.0
		let location = CLLocationCoordinate2D(latitude: bottomLeft.latitude + distance, longitude: bottomLeft.longitude + distance)

		TwitterTweetRequest(for: location, with: distance, using: TwitterConsumerAPIKey, and: twitterCredential).load { result in
			switch result {
			case .failure(let dataRequestError):
				completionHandler(.failure(dataRequestError))
				break
			case .success(let json):
				do {
					let info = try TwitterInfo(from: json)
					completionHandler(.success(info))
				}
				catch {
					completionHandler(.failure(DataRequestError.decodeDataError))	// TODO: change to more specific error
				}
				break
			}
		}

/*
https://api.twitter.com/1.1/geo/reverse_geocode.json
lat	required	The latitude to search around. This parameter will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding long parameter.		37.7821120598956
long	required	The longitude to search around. The valid ranges for longitude are -180.0 to +180.0 (East is positive) inclusive. This parameter will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding lat parameter.		-122.400612831116
accuracy	optional	A hint on the "region" in which to search. If a number, then this is a radius in meters, but it can also take a string that is suffixed with ft to specify feet. If this is not passed in, then it is assumed to be 0m. If coming from a device, in practice, this value is whatever accuracy the device has measuring its location (whether it be coming from a GPS, WiFi triangulation, etc.).	0m	500ft
granularity	optional
This is the minimal granularity of place types to return and must be one of: neighborhood, city, admin or country . If no granularity is provided for the request neighborhood is assumed.
Setting this to city, for example, will find places which have a type of city, admin or country.
neighborhood	city
max_results	optional	A hint as to the number of results to return. This does not guarantee that the number of results returned will equal max_results, but instead informs how many "nearby" results to return. Ideally, only pass in the number of places you intend to display to the user here.
*/
//		let searchText = "-kid -kids -child -children " + searchText
//		let bottomLeft = bottomLeft
//		let topRight = topRight
//		let maximumNumberOfPhotos = maximumNumberOfPhotos
//		let searchURLString = buildSearchStringForLocationBottomLeft(_searchText, bottomLeft: _bottomLeft, topRight: _topRight,
//			numberOfPhotos: maximumNumberOfPhotos, page: 0)
//
//		requestPhotoAnnotations(searchURLString, completionHandler: completionHandler)
	}

//	func getTweets(_ searchURLString: String, completionHandler: @escaping (Swift.Result<FlickrPhotoInfo?, Error>) -> Void) {
//		let dataRequest = TwitterRequest(endpointURL: searchURLString)
//		_ = dataRequest.load() { result in
//			switch result {
//			case .failure(_):
//				break
//			case .success(let photoJSON):
//				break
//		}
//	}
}

class TwitterTweetRequest: TwitterAppUserAuthenticatedRequest {
	var oauthConsumerKey: String
	var twitterCredential: SwifterCredential

	internal var endpointURL: String
	init(for location: CLLocationCoordinate2D, with accuracy: Double, using oauthConsumerKey: String, and twitterCredential: SwifterCredential) {
		self.oauthConsumerKey = oauthConsumerKey
		self.twitterCredential = twitterCredential
		self.endpointURL = "https://api.twitter.com/1.1/geo/reverse_geocode.json?lat=\(location.latitude)&lon=\(location.longitude)&accuracy=\(accuracy)"
	}
}


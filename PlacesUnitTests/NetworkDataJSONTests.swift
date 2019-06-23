//
//  NetworkDataJSONTests.swift
//  PlacesUnitTests
//
//  Created by Michael Valentiner on 3/25/19.
//  Copyright © 2019 Michael Valentiner. All rights reserved.
//

import XCTest
@testable import Places

class NetworkDataJSONTests: XCTestCase {

    func testFlickrRequest() {
		class SuccessFlickrDataRequest: UnauthenticatedDataRequest {
			typealias RequestedDataType = [String : JSON]
			var endpointURL: String {
				get { return "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=3a95d51756054b5b3e1cf23ff6b9f945&format=json&extras=geo,media=photos,url_s,url_t,url_q,url_k,url_h,url_b,url_c,url_z&sort=interestingness-desc&nojsoncallback=1&per_page=4&page=0&" }
			}
		}

    	let expectation = XCTestExpectation(description: "Test NetworkDataRequestTests.testDataRequest_Load")
		let dataRequest = SuccessFlickrDataRequest()
		do {
			_ = try dataRequest.load().done { photoInfo in
//				print("\(photoInfo)")
				XCTAssertTrue(photoInfo["stat"] == "ok")
				expectation.fulfill()
			}.catch { error in
				print("error = \(error)")
				XCTAssertTrue(false)
				expectation.fulfill()
			}
		} catch (let error) {
			XCTAssertTrue(false, "error = \(error)")
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 10.0)
    }
}

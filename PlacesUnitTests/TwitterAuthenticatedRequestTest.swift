//
//  TwitterAuthenticatedRequestTest.swift
//  PlacesUnitTests
//
//  Created by Michael Valentiner on 8/25/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import XCTest
@testable import Places

class TwitterAuthenticatedRequestTest: XCTestCase {

	class TwitterTestRequest: TwitterAuthenticatedRequest {
//		var endpointURL: String = "https://api.twitter.com/1.1/geo/reverse_geocode.json?lat=37.781157&long=-122.398720&granularity=neighborhood"
//		var endpointURL: String = "https://api.twitter.com/1.1/geo/search.json?query=Toronto"
		var endpointURL: String = "https://api.twitter.com/1.1/geo/search.json?query=Toronto"
	}

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMakeRequest() {
    	let _ = TwitterTestRequest().makeRequest(for: URL(string: TwitterTestRequest().endpointURL)!)
//    	print("urlRequest = \(urlRequest)")
		XCTAssertTrue(true)
    }

    func testRequest() {
    	let expectation = XCTestExpectation(description: "Test \(#function)")
		TwitterTestRequest().load { (decodableRequestResult) in
			print("decodableRequestResult == \(decodableRequestResult)")
			switch decodableRequestResult {
			case .failure(let error):
				XCTFail("error == \(error)")
				break
			case .success(let json):
				XCTAssert(true, "json == \(json)")
				break
			}
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 10.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

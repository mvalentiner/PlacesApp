//
//  TwitterBearerTokenRequestTest.swift
//  PlacesUnitTests
//
//  Created by Michael Valentiner on 8/17/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import XCTest
@testable import Places

class TwitterBearerTokenRequestTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTokenRequest() {
    	let expectation = XCTestExpectation(description: "Test \(#function)")
		TwitterBearerTokenRequest().getToken { (tokenRequestResult) in
			print("tokenRequestResult == \(tokenRequestResult)")
			switch tokenRequestResult {
			case .failure(let error):
				XCTFail("error == \(error)")
				break
			case .success(let token):
				XCTAssert(true, "token == \(token)")
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

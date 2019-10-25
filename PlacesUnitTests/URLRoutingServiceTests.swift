//
//  URLRoutingServiceTests.swift
//  PlacesUnitTests
//
//  Created by Michael Valentiner on 10/23/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

@testable import Places
import XCTest

class URLRoutingServiceTests: XCTestCase {
	
	private class AppPropertiesServiceTestImpl: AppPropertiesServiceImplementation {
		override var bundle: Bundle {
			get {
				return Bundle(identifier: "com.heliotropix.PlacesTests")!	// Intentional force unwrapped.
			}
		}
	}

	private let appPropertiesService = AppPropertiesServiceTestImpl()

	// Create a URLRoutingService with a mock AppPropertiesServiceImplementation.
	private var urlRoutingService: URLRoutingService = URLRoutingServiceImplementation(using: AppPropertiesServiceTestImpl())

    override func setUp() {
		/*
			This test requires PlacesUnitTests-Info.plist be populated with test data as follows:
			<key>CFBundleURLTypes</key>
			<array>
				<dict>
					<key>CFBundleURLName</key>
					<string>com.heliotropix.Places-0</string>
					<key>CFBundleURLSchemes</key>
					<array>
						<string>helioplaces-0-0</string>
						<string>helioplaces-0-1</string>
					</array>
				</dict>
				<dict>
					<key>CFBundleURLName</key>
					<string>com.heliotropix.Places-1</string>
					<key>CFBundleURLSchemes</key>
					<array>
						<string>helioplaces-1-0</string>
						<string>helioplaces-1-1</string>
					</array>
				</dict>
			</array>
		*/
		urlRoutingService.add(handler: handleUrl, for: "testHandleURL")
		urlRoutingService.add(handler: handleUrlWithParameters, for: "testWithParameters")
    }

    func testHandleURL() {
		let url = URL(string: "helioplaces-0-0://testHandleURL/test")!
		XCTAssertTrue(urlRoutingService.handle(url, options: [:]))
    }
			
	private func handleUrl(url: URL, operation: String, parameters : Dictionary<String, String>) -> Bool {
		guard operation == "test" else {
			// Unsupported operation.
			// TODO: handle? log? fatal?
			return false
		}

		return true
	}

	func testHandleURLWithPath() {
		let url1 = URL(string: "helioplaces-0-0://testHandleURL/test/more")!
		XCTAssertTrue(urlRoutingService.handle(url1, options: [:]))
		let url2 = URL(string: "helioplaces-0-0://testHandleURL/test/more/and/more")!
		XCTAssertTrue(urlRoutingService.handle(url2, options: [:]))
	}

	func testHandleURLWithParameters() {
		let url1 = URL(string: "helioplaces-0-0://testWithParameters/parameters?param1=param1")!
		XCTAssertTrue(urlRoutingService.handle(url1, options: [:]))
		let url2 = URL(string: "helioplaces-0-0://testWithParameters/parameters?param1=param1&param2=param2")!
		XCTAssertTrue(urlRoutingService.handle(url2, options: [:]))
	}
	
	private func handleUrlWithParameters(url: URL, operation: String, parameters : Dictionary<String, String>) -> Bool {
		guard operation == "parameters" else {
			// Unsupported operation.
			// TODO: handle? log? fatal?
			return false
		}

		return parameters.isEmpty != true
	}
}

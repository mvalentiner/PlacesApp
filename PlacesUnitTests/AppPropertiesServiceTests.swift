//
//  AppPropertiesServiceTests.swift
//  PlacesUnitTests
//
//  Created by Michael Valentiner on 10/10/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

@testable import Places
import XCTest

class AppPropertiesServiceTests: XCTestCase {

	private class AppPropertiesServiceTestImpl: AppPropertiesServiceImplementation {
		override var bundle: Bundle {
			get {
				return Bundle(identifier: "com.heliotropix.PlacesTests")!	// Intentional force unwrapped.
			}
		}
	}

	private let appPropertiesService = AppPropertiesServiceTestImpl()

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
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBundleIdentity() {
    	// This test tests that we are running against the correct Bundle, defined by PlacesUnitTests-Info, and that
    	// AppPropertiesServiceTestImpl is implemented correctly to use it.
		guard let bundle = Bundle(identifier: "com.heliotropix.PlacesTests") else {
			XCTAssert(false, "Bundle(identifier: \"com.heliotropix.PlacesTests\") not found")
			return
		}
		XCTAssert(appPropertiesService.bundle.bundleIdentifier == bundle.bundleIdentifier)
    }

	func testAppSchemes() {
		let appSchemes = appPropertiesService.appCustomURLSchemes
		XCTAssert(appSchemes.contains("helioplaces-0-0"))
		XCTAssert(appSchemes.contains("helioplaces-0-1"))
		XCTAssert(appSchemes.contains("helioplaces-1-0"))
		XCTAssert(appSchemes.contains("helioplaces-1-1"))
	}
}

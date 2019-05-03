//
//  NetworkDataRequestTests.swift
//  Places NearTests
//
//  Created by Michael Valentiner on 3/15/19.
//  Copyright © 2019 Michael Valentiner. All rights reserved.
//

import XCTest
@testable import Places

class NetworkDataRequestTests: XCTestCase {
	private enum CodingKeys : String, CodingKey {
		case results
		case version
	}
	struct GoodAppStoreInfo : Decodable {
		internal let version : String
		init(from decoder: Decoder) throws {
			// {"results": [{"version":"2.2"},]}
			let container = try decoder.container(keyedBy: CodingKeys.self)
			var resultArray	= try container.nestedUnkeyedContainer(forKey: .results)
			let result = try resultArray.nestedContainer(keyedBy: CodingKeys.self)
			let version = try result.decode(String.self, forKey: .version)
			self.version = version
		}
	}
	func testDataRequest_Load_Success() {
		class SuccessTestDataRequest : UnauthenticatedDataRequest {
			typealias RequestedDataType = GoodAppStoreInfo
			var endpointURL: String {
				get { return "https://itunes.apple.com/lookup?bundleId=com.heliotropix.Photos-Near" }
			}
		}

    	let expectation = XCTestExpectation(description: "Test NetworkDataRequestTests.testDataRequest_Load")
		let dataRequest = SuccessTestDataRequest()
		do {
			_ = try dataRequest.load().done { appStoreInfo in
				let versionNumber = Double(appStoreInfo.version)
				XCTAssertTrue(versionNumber != nil)
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

	/// testDataRequest_BadDecode_Fail
	func testDataRequest_BadDecode_Fail() {
		struct BadAppStoreInfo : Decodable {
			internal let version : String
			init(from decoder: Decoder) throws {
				// {"results": [{"version":"2.2"},]}
				let container = try decoder.container(keyedBy: CodingKeys.self)
				let version = try container.decode(String.self, forKey: .version)
				self.version = version
			}
		}
		class BadDecodeTestDataRequest : UnauthenticatedDataRequest {
			typealias RequestedDataType = BadAppStoreInfo
			var endpointURL: String {
				get { return "https://itunes.apple.com/lookup?bundleId=com.heliotropix.Photos-Near" }
			}
		}

    	let expectation = XCTestExpectation(description: "Test NetworkDataRequestTests.testDataRequest_Load")
		let dataRequest = BadDecodeTestDataRequest()
		do {
			_ = try dataRequest.load().done { _ in
				XCTAssertTrue(false)
				expectation.fulfill()
			}.catch { error in
				print("error = \(error)")
				XCTAssertTrue(true)
				expectation.fulfill()
			}
		} catch (let error) {
			print("error = \(error)")
			XCTAssertTrue(true)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 10.0)
	}

	/// testDataRequest_BadEndpoint_Fail
	func testDataRequest_BadEndpoint_Fail() {
		class BadEndpointTestDataRequest : UnauthenticatedDataRequest {
			typealias RequestedDataType = GoodAppStoreInfo
			var endpointURL: String {
				get { return "https://foo.bar" }
			}
		}

    	let expectation = XCTestExpectation(description: "Test NetworkDataRequestTests.testDataRequest_Load")
		let dataRequest = BadEndpointTestDataRequest()
		do {
			_ = try dataRequest.load().done { _ in
				XCTAssertTrue(false)
				expectation.fulfill()
			}.catch { error in
				print("error = \(error)")
				XCTAssertTrue(true)
				expectation.fulfill()
			}
		} catch (let error) {
			print("error = \(error)")
			XCTAssertTrue(true)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 10.0)
	}
}

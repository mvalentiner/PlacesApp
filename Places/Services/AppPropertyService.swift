//
//  AppProperties.swift
//  Places
//
//  Created by Michael Valentiner on 3/20/19.
//  Copyright © 2019 Michael Valentiner. All rights reserved.
//

import Foundation

internal struct AppPropertiesServiceName {
	static let name = "AppPropertiesService"
}

extension ServiceRegistryImplementation {
	var appPropertiesService: AppPropertiesService {
		get {
			return serviceWith(name: AppPropertiesServiceName.name) as! AppPropertiesService	// Intentional forced unwrapping
		}
	}
}

protocol AppPropertiesService: SOAService {
	var appAppStoreURL: String { get }
	var appBuildNumber: String { get }
	var appCustomURLSchemes: [String] { get }
	var appStoreId: String { get }
	var appVersion: String { get }
	var bundle: Bundle { get }
	var settingsModel: SettingsDataModel { get }
}

extension AppPropertiesService {
	// MARK: Service protocol requirement
	internal var serviceName: String {
		get {
			return AppPropertiesServiceName.name
		}
	}

	// MARK: AppPropertiesService service implementation

	internal var appAppStoreURL: String {
		get {
			return getPropertyListString(forKey: "AppAppStoreURL")
		}
	}

    internal var appBuildNumber: String {
        get {
            return getPropertyListString(forKey: "CFBundleVersion")
        }
    }
	
	internal var appCustomURLSchemes: [String] {
		guard let customURLTypes = bundle.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [Dictionary<String, Any>] else {
			fatalError("Error: No plist entry for CFBundleURLTypes")
		}
		let schemes = customURLTypes.reduce(into: [String](), { (accumulatingResult: inout [String], dict: Dictionary<String, Any>) in
			guard let customURLSchemes = dict["CFBundleURLSchemes"] as? [String], customURLSchemes.isEmpty == false else {
				fatalError("Error: CFBundleURLTypes is empty")
			}
			accumulatingResult.append(contentsOf: customURLSchemes)
		})

		return schemes
	}

	internal var appStoreId: String {
		get {
			let appStoreUrl = URL(string: getPropertyListString(forKey: "AppAppStoreURL"))
			let idPath = appStoreUrl?.lastPathComponent
			guard let id = idPath?.replacingOccurrences(of: "id", with: "") else {
				fatalError("Developer error. AppstoreURL is missing from plist")
			}
			return id
		}
	}
	
	internal var appVersion: String {
		get {
			return getPropertyListString(forKey: "CFBundleShortVersionString")
		}
	}

	//** Private helper functions

	private func getPropertyListString(forKey: String) -> String {
		guard let value = bundle.object(forInfoDictionaryKey: forKey) as? String else {
			fatalError("Error: No plist entry for \(forKey)")
		}
		return value
	}
	
    private func getBundleResourcePath(forFileName resource: String, withExtension type: String) -> String {
        guard let path = bundle.path(forResource: resource, ofType: type) else {
            fatalError("Error: \(resource).\(type) does not exist in app bundle")
        }
        return path
    }
}

internal class AppPropertiesServiceImplementation: AppPropertiesService {
	@discardableResult
	static func register() -> AppPropertiesServiceImplementation {
		let service = AppPropertiesServiceImplementation()
		service.register()
		return service
	}

	// This is here primarily for unit testing. When executed in the test evironment, Bundle.main is the XCTesting tool.
	internal var bundle: Bundle {
		get {
			return Bundle.main
		}
	}
	/// SettingsDataModel
	static private var settingsDataModel = SettingsDataModel()

	internal var settingsModel: SettingsDataModel {
		get {
			return AppPropertiesServiceImplementation.settingsDataModel
		}
	}
}

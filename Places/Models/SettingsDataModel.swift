//
//  SettingsDataModel.swift
//  Places
//
//  Created by Michael Valentiner on 9/30/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import SwiftUI
import Combine

protocol FlickrPlaceDataModel {
    var flickrIsActive: Bool { get set }
}

protocol TwitterPlaceDataModel {
    var twitterIsActive: Bool { get set }
}

/// SettingsDataModel acts as a ViewModel for the SettingsScreen, but it also maintains and acts as a persitent property store for the application for some staate data.
class SettingsDataModel: ObservableObject, FlickrPlaceDataModel, TwitterPlaceDataModel {

	@Published var flickrIsActive: Bool = UserDefaults.standard.bool(forKey: "flickrIsActive") {
		didSet {
			UserDefaults.standard.set(self.flickrIsActive, forKey: "flickrIsActive")
		}
	}

	@Published var twitterIsActive: Bool = UserDefaults.standard.bool(forKey: "twitterIsActive") {
		didSet {
			UserDefaults.standard.set(self.twitterIsActive, forKey: "twitterIsActive")
		}
	}
	
	// Transient, non-persistent state for the Settings UI.
	var isLoggedInToTwitter: Bool = false
}

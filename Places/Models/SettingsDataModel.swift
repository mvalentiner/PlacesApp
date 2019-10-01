//
//  SettingsDataModel.swift
//  Places
//
//  Created by Michael Valentiner on 9/30/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import SwiftUI
import Combine

class SettingsDataModel: ObservableObject {

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
}

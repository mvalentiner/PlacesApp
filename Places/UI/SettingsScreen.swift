//
//  SettingsScreen.swift
//  Places
//
//  Created by Michael Valentiner on 9/27/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import SwiftUI

struct SettingsScreen: View {
	private let mainController: MainCoordinatorService

    @EnvironmentObject private var settings: SettingsDataModel

    init(mainController: MainCoordinatorService) {
    	self.mainController = mainController
	}

	var body: some View {
		VStack {
			Divider()
			HStack {
				Image("flickr")
					.padding(.leading, 10)
				Toggle(isOn: $settings.flickrIsActive) {
					Text("Flickr")
						.font(.headline)
						.padding(.leading, 10)
				}
				.padding(.trailing, 20)
			}
			Divider()
			HStack {
				Image("twitter")
					.padding(.leading, 10)
				if settings.hasTwitterAccessToken {
					Toggle(isOn: $settings.twitterIsActive) {
						Text("Twitter")
							.font(.headline)
							.padding(.leading, 10)
					}
					.padding(.trailing, 20)
				}
				else {
					Text("Twitter")
						.font(.headline)
						.padding(.leading, 10)
					Spacer()
					Button(action: {
						self.mainController.navigateToTwitterLogin()
					}) {
						Text("Login")
						.padding(.leading, 10)
						.padding(.trailing, 20)
					}
				}
			}
			Divider()
			Spacer()
		}
		.padding(.top, 100)
	}
}

struct SettingsView_Previews: PreviewProvider {
	@State static var settings = SettingsDataModel()
    static var previews: some View {
		SettingsScreen(mainController: ServiceRegistry.mainCoordinator)
    }
}

//
//  SettingsScreen.swift
//  Places
//
//  Created by Michael Valentiner on 9/27/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import SwifteriOS
import SwiftUI

struct SettingsScreen: View {
	private let mainController: MainCoordinatorService

    @EnvironmentObject private var settings: SettingsDataModel

    init(mainController: MainCoordinatorService) {
    	self.mainController = mainController
	}

	var body: some View {
		VStack {
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
			HStack {
				Image("twitter")
					.padding(.leading, 10)
				Toggle(isOn: $settings.twitterIsActive) {
					Text("Twitter")
						.font(.headline)
						.padding(.leading, 10)
				}
				.padding(.trailing, 20)
			}
		}
	}

	func didTouchUpInsideLoginButton() {
		let failureHandler: (Error) -> Void = { error in
//			self.alert(title: "Error", message: error.localizedDescription)
			print("Error == \(error.localizedDescription)")
		}
		let swifter = Swifter(consumerKey: TwitterConsumerAPIKey, consumerSecret: TwitterConsumerAPISecretKey)
//print("accessToken == \(String(describing: swifter.client.credential?.accessToken))")
		let url = URL(string: "helioplaces://twitterAuthorizeSuccess")!
		swifter.authorize(withCallback: url, presentingFrom: self.mainController.rootController.topViewController, success: { _, _ in
//print("accessToken == \(String(describing: swifter.client.credential?.accessToken))")
			self.mainController.popToRootController()
		}, failure: failureHandler)
	}
}

struct SettingsView_Previews: PreviewProvider {
	@State static var settings = SettingsDataModel()
    static var previews: some View {
		SettingsScreen(mainController: ServiceRegistry.mainCoordinator)
    }
}

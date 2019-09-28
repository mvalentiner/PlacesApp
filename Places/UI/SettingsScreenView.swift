//
//  SettingsScreenView.swift
//  Places
//
//  Created by Michael Valentiner on 9/27/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import SwifteriOS
import SwiftUI

struct SettingsScreenView: View {
	private let mainController: MainCoordinatorService

    var body: some View {
		Button(action: { self.didTouchUpInsideLoginButton() }) {
			Image("ButtonTwitterNormal")
				.padding(.leading, 10.0)
		}
    }
    
    init(with mainController: MainCoordinatorService) {
    	self.mainController = mainController
	}

	func didTouchUpInsideLoginButton() {
		let failureHandler: (Error) -> Void = { error in
//			self.alert(title: "Error", message: error.localizedDescription)
			print("Error == \(error.localizedDescription)")
		}
		let swifter = Swifter(consumerKey: TwitterConsumerAPIKey, consumerSecret: TwitterConsumerAPISecretKey)
print("accessToken == \(String(describing: swifter.client.credential?.accessToken))")
		let url = URL(string: "helioplaces://twitterAuthorizeSuccess")!
		swifter.authorize(withCallback: url, presentingFrom: self.mainController.rootController.topViewController, success: { _, _ in
print("accessToken == \(String(describing: swifter.client.credential?.accessToken))")
			self.mainController.popToRootController()
		}, failure: failureHandler)
	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreenView(with: ServiceRegistry.mainCoordinator)
    }
}

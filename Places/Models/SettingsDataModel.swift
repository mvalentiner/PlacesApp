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
	@Published var flickrIsActive: Bool
	@Published var twitterIsActive: Bool

	init() {
		self.flickrIsActive = false
		self.twitterIsActive = false
	}
}

//class DataStore: BindableObject {
//    let didChange = PassthroughSubject<DataStore, Never>()
//
//    @UserDefault(key: "Settings", defaultValue: [])
//    var settings: [Settings] {
//        didSet {
//            didChange.send(self)
//        }
//    }
//}


//
// class Settings: ObservableObject {
//
//   @Published var isLogedIn : Bool = false
//
// func doLogin(params:[String:String]) {
//
//        Webservice().login(params: params) { response in
//
//            if let myresponse = response {
//                    self.login = myresponse.login
//                    }
//               }
//         }
//
//}

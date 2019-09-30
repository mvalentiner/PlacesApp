//
//  UserDefaultPropertyWrapper.swift
//  Places
//
//  Created by Michael Valentiner on 9/30/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation
 
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
//
//import Combine
//import SwiftUI
//
//final class DataStore: BindableObject {
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
//import SwiftUI
//
//struct SettingsView : View {
//    @EnvironmentObject var dataStore: DataStore
//
//    var body: some View {
//        Toggle(isOn: $settings.space) {
//            Text("(settings.space)")
//        }
//    }
//}

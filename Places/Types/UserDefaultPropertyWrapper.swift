//
//  UserDefaultPropertyWrapper.swift
//  Places
//
//  Created by Michael Valentiner on 9/30/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation
 
@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
        	guard defaultValue is NSData ||
				defaultValue is NSString ||
				defaultValue is NSNumber ||
				defaultValue is NSDate ||
				defaultValue is NSArray ||
				defaultValue is NSDictionary else {
				guard let storedObject = UserDefaults.standard.object(forKey: key) as? Data else {
					return defaultValue
				}
				return try! PropertyListDecoder().decode(T.self, from: storedObject)
			}
			return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
        	guard newValue is NSData ||
				newValue is NSString ||
				newValue is NSNumber ||
				newValue is NSDate ||
				newValue is NSArray ||
				newValue is NSDictionary else {
				UserDefaults.standard.set(try! PropertyListEncoder().encode(newValue), forKey: key)
        		return
			}
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

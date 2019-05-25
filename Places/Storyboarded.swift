//
//  Storyboarded.swift
//  Places
//
//  Created by Michael Valentiner on 5/24/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//
// from https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

import UIKit

protocol Storyboarded {
	static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
	static func instantiate() -> Self {
		// this pulls out "MyApp.MyViewController"
		let fullName = NSStringFromClass(self)

		// this splits by the dot and uses everything after, giving "MyViewController"
		let className = fullName.components(separatedBy: ".")[1]

		// load our storyboard
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

		// instantiate a view controller with that identifier, and force cast as the type that was requested
		return storyboard.instantiateViewController(withIdentifier: className) as! Self
	}
}

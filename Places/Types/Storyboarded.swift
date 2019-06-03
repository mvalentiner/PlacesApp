//
//  Storyboarded.swift
//  Places
//
//  Created by Michael Valentiner on 5/24/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//
//	From https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

import UIKit

protocol Storyboarded {
	static func instantiate(fromStoryboardNamed filename: String) -> Self
}

extension Storyboarded where Self: UIViewController {
	static func instantiate(fromStoryboardNamed filename: String = "Main") -> Self {
		// this pulls out "MyApp.MyViewController"
		let fullName = NSStringFromClass(self)

		// this splits by the dot and uses everything after, giving "MyViewController"
		let className = fullName.components(separatedBy: ".")[1]

		// load our storyboard
		let storyboard = UIStoryboard(name: filename, bundle: Bundle.main)

		// instantiate a view controller with that identifier, and force cast as the type that was requested
		return storyboard.instantiateViewController(withIdentifier: className) as! Self
	}
}

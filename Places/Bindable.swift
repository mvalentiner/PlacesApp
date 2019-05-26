//
//  Bindable.swift
//  Places
//
//  Created by Michael Valentiner on 5/22/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//
// 	Inspired by
//		• https://www.swiftbysundell.com/posts/bindable-values-in-swift
//		• https://github.com/ReactiveCocoa/ReactiveSwift
//
///	Bindable is a small, minimal implementation of a generic type that can be bound to an action that gets
///	called (reacts) when its value changes.

import Foundation

struct Bindable<T> {
	typealias Observation<T> = (_ oldValue: T, _ newValue: T) -> Void
		/// Signature of the function that gets called when this Bindable's value changes report the oldValue and newValue.

    private var observations: [Observation<T>] = []
    	// A list of all active Observations.

    internal init(_ value: T) {
    	/// Creates a Binable qwith the given value.
        self.value = value
    }

    internal var value: T {
    	/// The value of what this Bindable binds to.
    	didSet {
    		/// When the value changes, tell all the observations and pass the new value.
    		observations.forEach { (observation) in
				observation(oldValue, value)
			}
    	}
	}
	
	internal mutating func bind(_ observation: @escaping Observation<T>) {
		/// Binds this Bindable's value to the observation.
		observations.append(observation)
	}
}

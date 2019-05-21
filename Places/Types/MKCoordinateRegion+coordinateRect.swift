//
//  MKCoordinateRegion+coordinateRect.swift
//  Places
//
//  Created by Michael Valentiner on 5/20/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
	internal func coordinateRect() -> CoordinateRect {
		let topRight = CLLocationCoordinate2D(
			latitude:center.latitude + (span.latitudeDelta / 2.0), longitude:center.longitude + (span.longitudeDelta / 2.0))
		let bottomLeft = CLLocationCoordinate2D(
			latitude:center.latitude - (span.latitudeDelta / 2.0), longitude:center.longitude - (span.longitudeDelta / 2.0))
		return CoordinateRect(topRight: topRight, bottomLeft: bottomLeft)
	}
}

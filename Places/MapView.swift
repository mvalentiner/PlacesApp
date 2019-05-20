//
//  MapView.swift
//  Places
//
//  Created by Michael Valentiner on 5/20/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import Foundation
import MapKit
import ReactiveSwift

class MapView : MKMapView {

	internal var placeAnnotations = MutableProperty<[PlaceAnnotation]>([])

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		showsUserLocation = true
		userTrackingMode = MKUserTrackingMode.none
	}

	internal func centerMap(onLocation location: CLLocation) {
		let initialSpan = MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1)
		let initialRegion = MKCoordinateRegion(center: location.coordinate, span: initialSpan)
		region = initialRegion	// this causes mapView(_:regionDidChangeAnimated:) to get called
		centerCoordinate = location.coordinate
	}

	internal func visibleRect() -> CoordinateRect {
		let topRight = CLLocationCoordinate2D(
			latitude:(centerCoordinate.latitude + region.span.latitudeDelta),
			longitude:(centerCoordinate.longitude + region.span.longitudeDelta))
		let bottomLeft = CLLocationCoordinate2D(
			latitude:(region.center.latitude - region.span.latitudeDelta),
			longitude:(centerCoordinate.longitude - region.span.longitudeDelta))
		return CoordinateRect(topRight: topRight, bottomLeft: bottomLeft)
	}

	internal func updateMap() {
		DispatchQueue.main.async {
			self.placeAnnotations.value.forEach { (annotation) in
				self.addAnnotation(annotation)
			}

			self.setNeedsDisplay()
		}
	}
}

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

	internal required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		showsUserLocation = true
		userTrackingMode = MKUserTrackingMode.none
	}

	internal func removeAnnotations() {
		super.removeAnnotations(placeAnnotations.value)
		placeAnnotations.value.removeAll(keepingCapacity: true)
	}

	internal func centerMap(onLocation location: CLLocation) {
		let initialSpan = MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1)
		let initialRegion = MKCoordinateRegion(center: location.coordinate, span: initialSpan)
		region = initialRegion	// this causes mapView(_:regionDidChangeAnimated:) to get called
		centerCoordinate = location.coordinate
	}

	internal func updateMap(withPlaces places: [Place], andAnnotationDelegate delegate: PlaceAnnotationDelegate) {
		DispatchQueue.main.async {
			places.forEach { (place) in
				self.addAnnotation(PlaceAnnotation(withPlace: place, andDelegate: delegate))
			}
			self.setNeedsDisplay()
		}
	}

	private let smallestScreenDimension = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)

	internal func placeAnnotationView(for annotation: PlaceAnnotation) -> MKAnnotationView {
		let annotationView : MKAnnotationView = {
			let annotationViewId = "placeAnnotationId"
			guard let view = dequeueReusableAnnotationView(withIdentifier: annotationViewId) else {
				return MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewId)
			}
			return view
		}()
		annotationView.annotation = annotation
		annotationView.detailCalloutAccessoryView = nil

		// Determine our annotation size based on whether we have an image or not.
		var height = UIScreen.main.bounds.size.height * 0.334
		var width = UIScreen.main.bounds.size.height * 0.667
		if let image = annotation.image {
			let imageSize = image.size
			let maxImageDimension = max(imageSize.height, imageSize.width)
			
			let largestImageDimension = smallestScreenDimension * 0.667
			height = min((imageSize.height / maxImageDimension) * largestImageDimension, imageSize.height)
			width = min((imageSize.width / maxImageDimension) * largestImageDimension, imageSize.width)
		}

		// Build the view hierarchy.
		let containerView = UIView()
		var yOffset : CGFloat = 0.0
		if let titleText = annotation.title, titleText != "" {
			let textLabelHeight : CGFloat = 16.0
			let textLabelFrame = CGRect(x: 0.0, y: 0.0, width: width, height: textLabelHeight)
			let titleLabel = UILabel(frame: textLabelFrame)
			titleLabel.textAlignment = .center
			let attributedText = NSAttributedString(string: titleText, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
			titleLabel.attributedText = attributedText
			containerView.addSubview(titleLabel)
			titleLabel.anchorTo(left: containerView.leftAnchor, top: containerView.topAnchor, right: containerView.rightAnchor)
			titleLabel.constrainTo(height: textLabelHeight)
			yOffset += textLabelHeight + 4
		}

		if let image = annotation.image {
			let button = UIButton(type:UIButton.ButtonType.custom)
			let buttonYOffset = yOffset
			button.frame = CGRect(x: 0, y: buttonYOffset, width: width, height: buttonYOffset + height)
			button.addTarget(annotation, action: #selector(annotation.doButtonPress), for: UIControl.Event.touchUpInside)
			button.setImage(image, for: UIControl.State())
			containerView.addSubview(button)
			yOffset += buttonYOffset
		}

		containerView.constrainTo(width: width)
		containerView.constrainTo(height: yOffset + height)

		annotationView.detailCalloutAccessoryView = containerView
		annotationView.canShowCallout = true

		return annotationView
	}
}

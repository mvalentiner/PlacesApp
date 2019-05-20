//
//	MainViewController.swift
//	Places Near
//
//	Created by Michael Valentiner on 3/15/19.
//	Copyright © 2019 Michael Valentiner. All rights reserved.
//

import MBProgressHUD
import MapKit
import ReactiveSwift
import UIKit

class MainViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
	// MARK: Dependencies - Services are "injected" here.
	private let placesService = ServiceRegistry.placesService
	private let reachabilityService = ServiceRegistry.reachabilityService
	private let locationManager = CLLocationManager()

	// MARK: UI
	@IBOutlet private weak var mapView : MapView!
	private var progressView : MBProgressHUD?

	// MARK: State
	private var hasFirstLocation = false // This is used to make sure mapView(_:didUpdate:) is called before doing anything in mapView(_:regionDidChangeAnimated:)
	private var lastRequestedRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))

	// MARK: UIViewController overrides
	override func loadView() {
		super.loadView()

		mapView.delegate = self

		// Bind action to model
		mapView.placeAnnotations.bindTo {
			self.progressView?.hide(animated: true)
			self.progressView = nil
			self.mapView.updateMap()
		}

		// Create the ButtonBar.
		let infoButton = UIButton(type: .infoDark)
		infoButton.addTarget(self, action: #selector(handleInfoButtonTap), for: .touchUpInside)
		let buttonBarView = ButtonBarView(topButton: infoButton, bottomButton: MKUserTrackingButton(mapView: mapView))
		view.addSubview(buttonBarView)
		buttonBarView.anchorTo(top: view.safeAreaTopAnchor, right: view.safeAreaRightAnchor, topPadding: 48, rightPadding: 2)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		/// Initialize the locationManager.
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		locationManager.distanceFilter = 10.0
		if CLLocationManager.locationServicesEnabled() {
			locationManager.requestWhenInUseAuthorization()
		}
		else {
			// Location Services is not on
			showLocationServicesRequestDialog()
		}

		if let userLocation = locationManager.location {
			mapView.centerMap(onLocation: userLocation)
		}

//		createAndShowProgressHUD()

		self.reachabilityService.setReachableHandler { (reachability) in
			guard let window = self.view.window,
				let rootViewController = window.rootViewController,
				let navigationController = rootViewController as? UINavigationController,
				navigationController.topViewController == self else {
					return
			}
			if let presentedViewController = self.presentedViewController {
				presentedViewController.dismiss(animated: true)
			}
			self.requestMapPlacesAndUpdateAnnotations()
		}
	}

	@objc func handleInfoButtonTap() {
//		self.performSegue(withIdentifier: "segueToSettingsViewController", sender:self)
	}

	private func showLocationServicesRequestDialog() {
		let alertController = UIAlertController(
			title: "Places Near uses your location to find photos near you.",
			message: "Authorize access to your location to use Places Near. Go to Settings > Privacy > Location Services.",
			preferredStyle:UIAlertController.Style.alert)
		let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_: UIAlertAction) in
			UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
		}
		alertController.addAction(okAction)
		self.present(alertController, animated: true)
	}

	private func showProgressHUD() {
		guard self.progressView == nil else {
			return
		}

		let progressView = MBProgressHUD.showAdded(to: self.view, animated: true)
		progressView.graceTime = 0.5
		progressView.minShowTime = 1.0
		progressView.bezelView.alpha = 0.5
		progressView.bezelView.backgroundColor = UIColor.darkGray
		progressView.bezelView.isOpaque = false
		progressView.removeFromSuperViewOnHide = true
		self.progressView = progressView
	}

	// MARK: CLLocationManagerDelegate methods

	internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
			// we are authorized.
			locationManager.startMonitoringSignificantLocationChanges()
			guard let userLocation = locationManager.location else {
				return
			}
			mapView.centerMap(onLocation: userLocation)
		}
		else if status == CLAuthorizationStatus.denied {
			showLocationServicesRequestDialog()
		}
	}

	internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		if error._code == CLError.Code.denied.rawValue {
			showLocationServicesRequestDialog()
		}
		else {
			//TODO: alert the user?
		}
	}

	// MARK: MKMapViewDelegate methods

	private var didSelectAnnotation = false
		// didSelectAnnotation tracks when an annotation is selected so we don't make unnecessary calls to get more annoations, if
		// showing the annotation made the map move.

    internal func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		didSelectAnnotation = true
	}

    internal func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		didSelectAnnotation = false
	}

    internal func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		guard hasFirstLocation == true else {
			// Wait until mapView(_:didUpdate:) has been called
			return
		}
		guard self.isRegionChangeWithinTolerance(mapView, tolerance:0.334, withLastRegion: lastRequestedRegion) == false else {
			return
		}

		requestMapPlacesAndUpdateAnnotations()
	}

	private func isRegionChangeWithinTolerance(_ mapView: MKMapView, tolerance: Double, withLastRegion lastRegion: MKCoordinateRegion) -> Bool {
		let currentRegion = mapView.region
		let currentRegionInViewCoords = mapView.convert(currentRegion, toRectTo: mapView)

		let lastRegionInViewCoords = mapView.convert(lastRegion, toRectTo: mapView)

		let xMaxTolerance = Int(currentRegionInViewCoords.size.width * CGFloat(tolerance))

		let xOriginDelta = abs(Int(lastRegionInViewCoords.origin.x - currentRegionInViewCoords.origin.x))
		if xOriginDelta > xMaxTolerance {
			return false
		}

		let yMaxTolerance = Int(currentRegionInViewCoords.size.height * CGFloat(tolerance))

		let yOriginDelta = abs(Int(lastRegionInViewCoords.origin.y - currentRegionInViewCoords.origin.y))
		if yOriginDelta > yMaxTolerance {
			return false
		}

		return true
	}

	internal func mapView(_ mapView: MKMapView, didUpdate updatedUserLocation: MKUserLocation) {
		guard let userLocation = updatedUserLocation.location else {
			return
		}
		if hasFirstLocation == false {
			hasFirstLocation = true
			self.mapView.centerMap(onLocation: userLocation)
		}

		guard self.isRegionChangeWithinTolerance(mapView, tolerance:0.3333, withLastRegion: lastRequestedRegion) == false else {
			return
		}

		requestMapPlacesAndUpdateAnnotations()
	}

    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation is MKUserLocation == false else {
			// Don't return a view if the annotation is our location.
			return nil
		}
		guard let placeAnnotation = annotation as? PlaceAnnotation else {
			// If annotation is not a PlaceAnnotation, then we don't know what to do with it.
			return nil
		}
		let annotationView : MKAnnotationView = {
			let annotationViewId = "placeAnnotationId"
			guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewId) else {
				return MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewId)
			}
			return view
		}()
		annotationView.annotation = annotation
		annotationView.detailCalloutAccessoryView = nil

		let containerView = UIView()
		var yOffset : CGFloat = 0.0

		let textLabelHeight : CGFloat = 16.0
		let smallestScreenDimension = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
		let width = smallestScreenDimension * 0.667

		let titleLabel : UILabel = {
			let titleText = placeAnnotation.title ?? ""
			let textLabelFrame = CGRect(x: 0.0, y: 0.0, width: width, height: textLabelHeight)
			let label = UILabel(frame: textLabelFrame)
			label.textAlignment = .center
			let attributedText = NSAttributedString(string: titleText, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
			label.attributedText = attributedText
			label.translatesAutoresizingMaskIntoConstraints = false
			label.widthAnchor.constraint(equalToConstant: width).isActive = true
			label.heightAnchor.constraint(equalToConstant: textLabelHeight).isActive = true
			return label
		}()
		containerView.addSubview(titleLabel)
		yOffset += textLabelHeight + 4

//
//
//		if let image = placeAnnotation.previewImage {
//			let imageSize = image.size
//			let maxImageDimension = max(imageSize.height, imageSize.width)
//			let largestImageDimension = smallestScreenDimension * 0.667
//			let height = min((imageSize.height / maxImageDimension) * largestImageDimension, imageSize.height)
//			let width = min((imageSize.width / maxImageDimension) * largestImageDimension, imageSize.width)
//
//
//			let button = UIButton(type:UIButton.ButtonType.custom)
//			let buttonYOffset = yOffset
//			button.frame = CGRect(x: 0, y: buttonYOffset, width: width, height: buttonYOffset + height)
//			button.addTarget(photoAnnotation, action: #selector(PhotoAnnotation.doButtonPress), for: UIControl.Event.touchUpInside)
//			button.setImage(image, for: UIControl.State())
//			containerView.addSubview(button)
//			yOffset += buttonYOffset
//
//			containerView.translatesAutoresizingMaskIntoConstraints = false
//			containerView.widthAnchor.constraint(equalToConstant: width).isActive = true
//			containerView.heightAnchor.constraint(equalToConstant: yOffset + height).isActive = true
//
//			annotationView.detailCalloutAccessoryView = containerView
//			annotationView.canShowCallout = true
//		}
//		else {
//			print("photoAnnotation == \((annotation as? PhotoAnnotation).debugDescription)")
//			print("photoInfoDict == \(String(describing: (annotation as? PhotoAnnotation)?.photoInfoDict))")
//		}

		return annotationView
	}


	internal func requestMapPlacesAndUpdateAnnotations() {
		guard didSelectAnnotation == false else {
			// Don't get more annotations if the map is displaying an annotation.
			return
		}

//		showProgressHUD()

		lastRequestedRegion = mapView.region
		mapView.removeAnnotations(mapView.placeAnnotations.value)
		mapView.placeAnnotations.value.removeAll(keepingCapacity: true)

//		guard self.reachabilityService.isReachable == true else {
//			DispatchQueue.main.async {
//				if let progressView = self.progressView {
//					self.progressView = nil
//					progressView.hide(animated: true)
//				}
//				let alertController = UIAlertController(title: "Network", message: "Network is unavailable",
//					preferredStyle:UIAlertController.Style.alert)
//				let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
//				alertController.addAction(okAction)
//				self.present(alertController, animated: true, completion: {})
//			}
//			return
//		}

		let visibleRect = mapView.visibleRect()
		self.placesService.getPlaces(forRegion: visibleRect) { place in
			self.mapView.placeAnnotations.value.append(PlaceAnnotation(withPlace: place, andDelegate: self))
		}
	}
}

extension MainViewController : PlaceAnnotationDelegate {
    internal func handleAnnotationPress(forAnnotation annotation: PlaceAnnotation) {
//		self.selectedAnnotation = annotation
//TODO
//		self.performSegue(withIdentifier: "segueToPhotoView", sender:self)
	}
}

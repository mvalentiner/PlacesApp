//
//	MainViewController.swift
//	Places Near
//
//	Created by Michael Valentiner on 3/15/19.
//	Copyright © 2019 Michael Valentiner. All rights reserved.
//

import MBProgressHUD
import MapKit
import PMKFoundation
import UIKit

class MainViewController: UIViewController, Storyboarded, CLLocationManagerDelegate, MKMapViewDelegate {
	// MARK: Dependencies - Services are "injected" here rather than via an initializer because this is a Storyboard based UIViewController.
	private let mainCoordinator = ServiceRegistry.mainCoordinator
	private let placesService = ServiceRegistry.placesService
	private let reachabilityService = ServiceRegistry.reachabilityService
	private let locationManager = CLLocationManager()

	// MARK: UI
	@IBOutlet private weak var mapView: MapView!
	private var activityIndicator: MBProgressHUD?

	// MARK: State
	private var hasFirstLocation = false
		// This is used to make sure mapView(_:didUpdate:) is called before doing anything in mapView(_:regionDidChangeAnimated:)

	private var lastRequestedRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
		// Used to prevent small changes with the position/size of the map causing a calls to the place source services.

	// MARK: UIViewController overrides
	override func loadView() {
		super.loadView()

		mapView.delegate = self

		// Create and position the ButtonBar.
		let infoButton = UIButton(type: .infoDark)
		infoButton.addTarget(self, action: #selector(handleInfoButtonTap), for: .touchUpInside)
		let buttonBarView = ButtonBarView(topButton: infoButton, bottomButton: MKUserTrackingButton(mapView: mapView))
		view.addSubview(buttonBarView)
		buttonBarView.anchorTo(top: view.safeAreaTopAnchor, right: view.safeAreaRightAnchor, topPadding: 48, rightPadding: 2)
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		view.addGestureRecognizer(tapGestureRecognizer)
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
		
		self.requestMapPlacesAndUpdateAnnotations()
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		navigationController?.isNavigationBarHidden = true
	}

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
		navigationController?.hidesBarsOnTap = false
	}

	@objc func handleTap(sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			// handling code
		}
	}

	@objc func handleInfoButtonTap() {
		mainCoordinator.navigateToInfoScreen()
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

	private func showActivityIndicator() {
		guard self.activityIndicator == nil else {
			return
		}

		let progressView = MBProgressHUD.showAdded(to: self.view, animated: true)
		progressView.graceTime = 0.5
		progressView.minShowTime = 1.0
		progressView.bezelView.alpha = 0.5
		progressView.bezelView.backgroundColor = UIColor.darkGray
		progressView.bezelView.isOpaque = false
		progressView.removeFromSuperViewOnHide = true
		self.activityIndicator = progressView
	}

	private func dismissActivityIndicator() {
		self.activityIndicator?.hide(animated: true)
		self.activityIndicator = nil
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

    internal func mapView(_ mkMapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation is MKUserLocation == false else {
			// Don't return a view if the annotation is our location.
			return nil
		}
		guard let placeAnnotation = annotation as? PlaceAnnotation else {
			// If annotation is not a PlaceAnnotation, then we don't know what to do with it.
			return nil
		}
		guard let mapView = mkMapView as? MapView else {
			// If mkMapView is not a MapView, then we don't know what to do.
			return nil
		}
		return mapView.placeAnnotationView(for: placeAnnotation)
	}

	internal func requestMapPlacesAndUpdateAnnotations() {
		guard didSelectAnnotation == false else {
			// Don't get more annotations if the map is displaying an annotation.
			return
		}

		showActivityIndicator()
		mapView.removeAllAnnotations()
		lastRequestedRegion = mapView.region

		let visibleRect = mapView.region.coordinateRect()
		self.placesService.getPlaces(forRegion: visibleRect) { result in
			self.dismissActivityIndicator()
			switch result {
			case .failure(let error):
				let message: String = {
					let message = "An error ocurred trying to reach the server."
					guard let pmkHTTPError = error as? PMKFoundation.PMKHTTPError,
						let errorDescription = pmkHTTPError.errorDescription,
						let index = errorDescription.range(of: " for")?.lowerBound,
							// Trim the message to make it nicer to present to the user.
						let statusMessage = pmkHTTPError.errorDescription?.prefix(upTo: index) else {
						return message
					}
					return "\(message)\n\(statusMessage)"
				}()
				let alertController = UIAlertController(title: "Error", message: message, preferredStyle:UIAlertController.Style.alert)
				let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
				alertController.addAction(okAction)
				self.present(alertController, animated: true, completion: {})
			case .success(let place):
				guard let place = place else {
					return
				}
				let annotation = PlaceAnnotation(withPlace: place, andDelegate: self)
				self.mapView.add(placeAnnotation: annotation)
			}
		}
	}
}

extension MainViewController: PlaceAnnotationDelegate {
    internal func handleAnnotationPress(forAnnotation annotation: PlaceAnnotation) {
		mainCoordinator.navigateToPlaceDetailsScreen(for: annotation.place)
	}
}

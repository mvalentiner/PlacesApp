//
//  FlickrPlaceDetailsViewController.swift
//  Places
//
//  Created by Michael Valentiner on 5/27/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import UIKit

class FlickrPlaceDetailsViewController: UIViewController, UIScrollViewDelegate {
	// Dependenices
	let placeSource: InterestingnessPlaceSource

	// Model
	private let place: Place

	// UI
	private var imageView: UIImageView!

	init(for place: Place, with placeSource: InterestingnessPlaceSource) {
		self.place = place
		self.placeSource = placeSource
    	super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		super.loadView()
		//	view hierarchy
		//	- view
		//		- scrollView
		//			- UIImageView
		//		- info overlay
		// Root container view.
		let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
		self.view = {
			let view = UIView(frame: frame)
			return view
		}()

		// Image scroller
		let scrollView: UIScrollView = {
			let view = UIScrollView(frame: frame)
			view.delegate = self
			view.isUserInteractionEnabled = true
			view.maximumZoomScale = 16.0
			view.minimumZoomScale = 1.0
			return view
		}()
		self.view.addSubview(scrollView)
		scrollView.anchorTo(left: self.view.leftAnchor, top: self.view.topAnchor, right: self.view.rightAnchor, bottom: self.view.bottomAnchor)

		// Image view
		self.imageView = {
			let frame = CGRect(x: 0, y: -44, width: UIScreen.main.bounds.size.width, height: frame.size.height - 44)
			let view = UIImageView(frame: frame)
			view.contentMode = .scaleAspectFit
			view.isUserInteractionEnabled = true
//			// TODO:
//			guard let image = UIImage(named: "AnimatedPlaceholder") else {
//				fatalError("AnimatedPlaceholder.JPG is missing from app bundle.")
//			}
//			self.imageView.image = image
			return view
		}()
		scrollView.contentSize = imageView.bounds.size
		scrollView.addSubview(imageView)

		// Info overlay view
		let overlayView: UIView = {
			let view = UIView(frame: frame)
			view.isHidden = true	// TODO: remove
			return view
		}()
		self.view.addSubview(overlayView)
		overlayView.anchorTo(left: self.view.leftAnchor, top: self.view.topAnchor, right: self.view.rightAnchor, bottom: self.view.bottomAnchor)
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView?{
		return self.imageView
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		imageView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		navigationController?.hidesBarsOnTap = true
		navigationController?.isNavigationBarHidden = false

		placeSource.getPlaceDetail(for: place, completionHandler: { result in
			switch result {
			case .failure:
				// TODO: handle error
				break
			case .success(let details):
				DispatchQueue.main.async {
					guard let image = details?.images?[0] else {
						// TODO: handle no image.
						return
					}
					self.imageView.image = image
				}
				break
			}
		})
	}

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
		navigationController?.hidesBarsOnTap = false
	}
}

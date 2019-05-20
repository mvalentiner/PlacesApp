//
//  ButtonBarView.swift
//  Places
//
//  Created by Michael Valentiner on 5/20/19.
//  Copyright © 2019 Heliotropix, LLC. All rights reserved.
//

import MapKit
import UIKit

class ButtonBarView : UIStackView {

	required init(topButton: UIView, bottomButton: UIView) {
		super.init(frame: .zero)
		axis = .vertical
		distribution = .equalSpacing
		constrainTo(width: 44)
		constrainTo(height: 89)

		// Create the buttons for the buttonBarView.
		let topButtonItem = makeButtonBarItem(with: topButton, andRoundedCorners: [.layerMinXMinYCorner,.layerMaxXMinYCorner])
		insertArrangedSubview(topButtonItem, at: 0)

		let bottomButtonItem = makeButtonBarItem(with: bottomButton, andRoundedCorners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner])
		insertArrangedSubview(bottomButtonItem, at: 1)
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func makeButtonBarItem(with button: UIView, andRoundedCorners cornersMask: CACornerMask) -> UIView {
		let containerView = UIView()
		containerView.backgroundColor = .clear
		containerView.constrainTo(height: 44)

		let backgroundView = UIView()
		backgroundView.alpha = 0.333
		backgroundView.backgroundColor = .lightGray
		backgroundView.clipsToBounds = true
		backgroundView.constrainTo(height: 44)
		backgroundView.layer.cornerRadius = 10
		backgroundView.layer.maskedCorners = cornersMask

		containerView.addSubview(backgroundView)
		backgroundView.anchorTo(left: containerView.leftAnchor, top: containerView.topAnchor, right: containerView.rightAnchor, bottom: containerView.bottomAnchor)

		containerView.addSubview(button)
		button.anchorTo(left: containerView.leftAnchor, top: containerView.topAnchor, right: containerView.rightAnchor, bottom: containerView.bottomAnchor)
		return containerView
	}
}

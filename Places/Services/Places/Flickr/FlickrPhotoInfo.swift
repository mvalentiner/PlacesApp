//
//  FlickrPhotoInfo.swift
//  Photos Near
//
//  Created by Michael on 3/4/15.
//  Copyright (c) 2015 Heliotropix. All rights reserved.
//

import Foundation
import MapKit

struct FlickrPhotoInfo {
	let id : String
    let coordinate: CLLocationCoordinate2D
	let title: String
	let thumbnailImage : UIImage
	let photoURLString : String
	var image : UIImage? = nil
}

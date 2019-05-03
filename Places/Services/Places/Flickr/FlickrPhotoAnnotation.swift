//
//  FlickrPhotoAnnotation.swift
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

class FlickrPhotoAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
	let title: String? = nil	// Don't set the title becuase we use a custom view to display it.
	let subtitle: String? = nil
	let thumbnailImage : UIImage

	let photoInfo : FlickrPhotoInfo

	init(withPhotoInfo photoInfo: FlickrPhotoInfo) {
		coordinate = photoInfo.coordinate
		thumbnailImage = photoInfo.thumbnailImage
		self.photoInfo = photoInfo

		super.init()
	}

	@objc internal func doButtonPress() {
//		mapViewController.doButtonPress(self)
	}
}

/*
{
	accuracy = 16;
	context = 0;
	farm = 9;
	"geo_is_contact" = 0;
	"geo_is_family" = 0;
	"geo_is_friend" = 0;
	"geo_is_public" = 1;
	"height_m" = 334;
	"height_o" = 1367;
	"height_t" = 67;
	id = 16691739366;
	isfamily = 0;
	isfriend = 0;
	ispublic = 1;
	latitude = "40.744111";
	longitude = "-73.960638";
	owner = "48369971@N00";
	"place_id" = sTXjQKNTUb9enZi8dg;
	secret = 2571d359c8;
	server = 8619;
	title = im404593;
	"url_m" = "https://farm9.staticflickr.com/8619/16691739366_2571d359c8.jpg";
	"url_o" = "https://farm9.staticflickr.com/8619/16691739366_3b050c6118_o.jpg";
	"url_t" = "https://farm9.staticflickr.com/8619/16691739366_2571d359c8_t.jpg";
	"width_m" = 500;
	"width_o" = 2048;
	"width_t" = 100;
	woeid = 23511858;
}
*/

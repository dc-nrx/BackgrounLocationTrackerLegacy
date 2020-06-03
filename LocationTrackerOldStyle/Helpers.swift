//
//  Helpers.swift
//  LocationTracker
//
//  Created by Dmytro Chapovskyi on 29.03.2020.
//  Copyright © 2020 Dmytro Chapovskyi. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

typealias LocationTime = (location: CLLocation, date: Date)

func deviceId() -> String {
	UIDevice.current.identifierForVendor?.uuidString ?? "undefined"
}

extension CLLocation {
	
	var shortDescription: String {
		"(lat: \(coordinate.latitude), long: \(coordinate.longitude))"
	}
	
	func toJSON() -> JSON {
		return [
			"latitude": coordinate.latitude,
			"longitude": coordinate.longitude,
		]
	}
	
}

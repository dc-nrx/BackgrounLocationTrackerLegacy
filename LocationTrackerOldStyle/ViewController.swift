//
//  ViewController.swift
//  LocationTracker
//
//  Created by Dmytro Chapovskyi on 28.03.2020.
//  Copyright © 2020 Dmytro Chapovskyi. All rights reserved.
//

import UIKit
import CoreLocation

typealias JSON = [String: Any?]

class ViewController: UIViewController {

	@IBOutlet private var textView: UITextView!
	@IBOutlet private var deviceIdLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
			
		onRefresh()
		NotificationCenter.default.addObserver(forName: .loggerEntryAddedNotification, object: nil, queue: nil) { [weak self] (_) in
			DispatchQueue.main.async {
				self?.onRefresh()
			}			
		}
		
		deviceIdLabel.text = deviceId()
	}

	@IBAction func onRefresh(_ sender: Any? = nil) {
		if !textView.isHidden {
			textView.text = Logger.text
		}
	}
	
	@IBAction func onToggleLogShow(_ sender: Any? = nil) {
		textView.isHidden = !textView.isHidden
		textView.text = nil
	}

}


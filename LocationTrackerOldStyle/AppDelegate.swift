//
//  AppDelegate.swift
//  LocationTrackerOldStyle
//
//  Created by Dmytro Chapovskyi on 03.06.2020.
//  Copyright © 2020 Dmytro Chapovskyi. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	//MARK:- Configuration
	
	let enableBackgroundFetch = true
	
	let minimumBackgroundFetchInterval: TimeInterval = 15 * 60
	
	let urlString = "https://gtz-mobilehub-api-dev.azurewebsites.net/api/loads/34/gpsbulk"
	
	let apiKey = "aa57a8c49179781fd8f449a378e83f6c2f353e7a40b4ef6aab49a13df82a85bc"
	
	let useBackgroundTasksOnIOS13 = true
	
	//MARK:-
	
	private let bgTaskId = "dc.LocationTracker.sendLocation"
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		Logger.logAppLaunch()
		
		let headers = [
			"X-API-Key": apiKey,
			"deviceId": deviceId()
		]
		
		// Start tracking
		BackgroundLocationTracker.shared.start(url: NSURL(string: urlString)!, httpHeaders: headers)
		
		// Support relaunch on significant location change
		BackgroundLocationTracker.shared.continueIfAppropriate()
		Logger.log("\(#function)")
		
		if enableBackgroundFetch {
			if #available(iOS 13, *), useBackgroundTasksOnIOS13 {
				// Modern
				Logger.log("\(#function) - `BGTaskScheduler` flow")
				BGTaskScheduler.shared.register(forTaskWithIdentifier: bgTaskId, using: nil) { task in
					// Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
					self.handleAppRefresh(task: task as! BGAppRefreshTask)
				}
			}
			else {
				// Legacy (iOS <= 12)
				Logger.log("\(#function) - `setMinimumBackgroundFetchInterval` flow")
				UIApplication.shared.setMinimumBackgroundFetchInterval(minimumBackgroundFetchInterval)
			}
		}
		
		return true
	}
	
	
	@available(iOS 13.0, *)
	func handleAppRefresh(task: BGAppRefreshTask) {
		Logger.log("\(#function)")
		
		scheduleAppRefresh()
		
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		
		task.expirationHandler = {
			// After all operations are cancelled, the completion block below is called to set the task to complete.
			queue.cancelAllOperations()
		}
		
		queue.addOperation {
			BackgroundLocationTracker.shared.sendFromBackgroundFetch { (result) in
				task.setTaskCompleted(success: result != .failed)
			}
		}
	}
	
	@available(iOS 13.0, *)
	func scheduleAppRefresh() {
		Logger.log("\(#function)")
		let request = BGAppRefreshTaskRequest(identifier: bgTaskId)
		request.earliestBeginDate = Date(timeIntervalSinceNow: minimumBackgroundFetchInterval)
		do {
			try BGTaskScheduler.shared.submit(request)
			Logger.log("\(#function) - success")
		} catch {
			Logger.log("\(#function) ERROR - Could not schedule app refresh: \(error)")
		}
	}
	
	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		Logger.log(#function)
		BackgroundLocationTracker.shared.sendFromBackgroundFetch(completionHandler: completionHandler)
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		BackgroundLocationTracker.shared.willEnterBackground();
		Logger.log("\(#function)")
		
		if enableBackgroundFetch {
			if #available(iOS 13, *), useBackgroundTasksOnIOS13 {
				scheduleAppRefresh()
			}
		}
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		Logger.log("\(#function)")
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		Logger.log("\(#function)")
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		Logger.logAppTermination()
	}


}


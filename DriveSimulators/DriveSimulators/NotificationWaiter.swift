//
//  NotificationWaiter.swift
//  DriveSimulators
//
//  Created by Geoffrey Blotter on 11/16/15.
//  Copyright © 2015 LDS Church. All rights reserved.
//

import Foundation

class NotificationWaiter: AnyObject {
	
	private var date: NSDate?
	private let kTimeout:Double = 180
	
	var elapsedTime: NSTimeInterval {
		get {
			return date!.timeIntervalSinceNow * -1
		}
	}
	
	func start() {
		date = NSDate()
	}
	
	func wakeUpPeriodicallyForCheckingWithBlock( block: () -> Bool ) {
		var isRunning: Bool = true
		
		while isRunning {
			print( "Sleeping for a second..." )
			
			NSThread.sleepForTimeInterval( 1 )
			
			print( "Slept for: \(elapsedTime) seconds" )
			
			isRunning = block()
			
			if isRunning && isTimedOut() {
				print( "Timed out after \(kTimeout) seconds!" )
				isRunning = false
			}
			else {
				print( "isRunning: \(isRunning)" )
			}
		}
	}
	
	func isTimedOut() -> Bool {
		return elapsedTime > kTimeout
	}
	
}
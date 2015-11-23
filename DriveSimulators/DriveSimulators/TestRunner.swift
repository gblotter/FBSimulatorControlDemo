//
//  TestRunner.swift
//  DriveSimulators
//
//  Created by Geoffrey Blotter on 11/16/15.
//  Copyright © 2015 LDS Church. All rights reserved.
//

import Cocoa
import Foundation
import FBSimulatorControl


protocol SessionDefaultsProtocol {
	
	var managementOptions: FBSimulatorManagementOptions? {get set}
	var deviceSetPath: String? {get set}
	var _control: FBSimulatorControl? { get set }
	var control: FBSimulatorControl { get }
	
	func createSession( simConfig: FBSimulatorConfiguration? ) -> FBSimulatorSession?
	func createBootedSession( simConfig: FBSimulatorConfiguration? ) -> FBSimulatorSession?
}

extension SessionDefaultsProtocol {
	
	func createSession( simConfig: FBSimulatorConfiguration? = FBSimulatorConfiguration.iPhone6Plus() ) -> FBSimulatorSession? {
		let session: FBSimulatorSession
		
		do {
			session = try control.createSessionForSimulatorConfiguration( simConfig )
			return session
		}
		catch let error {
			print( "SessionDefaultsProtocol -> createSession(): Failed to createSession with the following error: \( error ) " )
			return nil
		}
	}
	
	func createBootedSession( simConfig: FBSimulatorConfiguration? = FBSimulatorConfiguration.iPhone6Plus() ) -> FBSimulatorSession? {
		guard let session: FBSimulatorSession = createSession( simConfig ) else {
			print( "SessionDefaultsProtocol -> createBootedSession(): Failed to create an FBSimulatorSession" )
			return nil
		}
		
		do {
			try session.interact().bootSimulator().performInteraction()
		}
		catch {
			print( "failed with error: \(error)" )
		}
		
		return session
	}
}

class TestRunner: NSObject, SessionDefaultsProtocol {
	
	var isRunning: Bool
	let notificationWaiter: NotificationWaiter
	
	var managementOptions: FBSimulatorManagementOptions?
	var deviceSetPath: String?
	
	var _control: FBSimulatorControl?
	var control: FBSimulatorControl {
		get {
			if let _ = _control {}
			else {
				let app: FBSimulatorApplication = try! FBSimulatorApplication( error: {}() )
				let config: FBSimulatorControlConfiguration = FBSimulatorControlConfiguration( simulatorApplication: app, deviceSetPath: deviceSetPath, options: managementOptions! )
				
				_control = FBSimulatorControl( configuration:  config )
			}
			
			return _control!
		}
	}
	
	
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver( self )
		
		do {
			try control.simulatorPool.killAll()
		}
		catch {
			print( "failed to kill all simulators in pool with the following error: \(error)" )
		}
		
		_control = nil
	}
	
	override init() {
		isRunning = false
		notificationWaiter = NotificationWaiter()
		
		managementOptions = [
			FBSimulatorManagementOptions.KillSpuriousSimulatorsOnFirstStart,
			FBSimulatorManagementOptions.IgnoreSpuriousKillFail,
			FBSimulatorManagementOptions.DeleteOnFree
		]
		
		deviceSetPath = nil
		
		super.init()
		
		let defaultCenter = NSNotificationCenter.defaultCenter()
		
		defaultCenter.addObserver( self, selector: "sessionDidStart:", name: FBSimulatorSessionDidStartNotification, object: nil )
		defaultCenter.addObserver( self, selector: "sessionDidEnd:", name: FBSimulatorSessionDidEndNotification, object: nil )

		defaultCenter.addObserver( self, selector: "simulatorDidLaunch:", name: FBSimulatorSessionSimulatorProcessDidLaunchNotification, object: nil )
		defaultCenter.addObserver( self, selector: "simulatorDidTerminate:", name: FBSimulatorSessionSimulatorProcessDidTerminateNotification, object: nil )
		
		defaultCenter.addObserver( self, selector: "applicationDidLaunch:", name: FBSimulatorSessionApplicationProcessDidLaunchNotification, object: nil )
		defaultCenter.addObserver( self, selector: "applicationDidTerminate:", name: FBSimulatorSessionApplicationProcessDidTerminateNotification, object: nil )

		defaultCenter.addObserver( self, selector: "agentDidLaunch:", name: FBSimulatorSessionAgentProcessDidLaunchNotification, object: nil )
		defaultCenter.addObserver( self, selector: "agentDidTerminate:", name: FBSimulatorSessionAgentProcessDidTerminateNotification, object: nil )
		
	}
	
	
	// MARK:
	
	func sessionDidStart( notification: NSNotification ) {
		logNotification( notification )
	}
	
	func sessionDidEnd( notification: NSNotification ) {
		logNotification( notification )
	}
	
	func simulatorDidLaunch( notification: NSNotification ) {
		logNotification( notification )
	}
	
	func simulatorDidTerminate( notification: NSNotification ) {
		logNotification( notification )
	}
	
	func applicationDidLaunch( notification: NSNotification ) {
		logNotification( notification )
	}
	
	func applicationDidTerminate( notification: NSNotification ) {
		logNotification( notification )
	}
	
	func agentDidLaunch( notification: NSNotification ) {
		logNotification( notification )
	}
	
	func agentDidTerminate( notification: NSNotification ) {
		logNotification( notification )
	}
	
	func logNotification( notification: NSNotification ) {
		print( "Received notification: \( notification.name )" )
	}
	
	
	// MARK:
	
	func run( appBuildPath path: String ) {
//		let bootedSession: FBSimulatorSession? = createBootedSession()
		let bootedSession: FBSimulatorSession? = createSession()
		
		guard let session = bootedSession else {
			print( "\(self.className) doTestLaunchesSingleSimulator(): Unable to create session" )
			return
		}
		
		let appLaunchConfig: FBApplicationLaunchConfiguration
		
		do {
			appLaunchConfig = try DemoFixture.demoAppLaunchWithTests( path )
		}
		catch {
			print( "failed with error: \(error)" )
			return
		}
		
		let app = appLaunchConfig.application
		var launchSuccess: Bool = false
		
		let group = dispatch_group_create()
		let queue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 )
		
		dispatch_group_async( group, queue, {
			
			do {
				
				try ( session.interact()
					.bootSimulator()
					.installApplication( app )
					.launchApplication( appLaunchConfig )
//					.sampleApplication( app, withDuration: 1, frequency: 1 )
					).performInteraction()
				
				let processId: Int = session.state.runningProcessForApplication( app ).processIdentifier
				
				print( "Session -> Application: \(app.name) -> procesId: \(processId)" )
				print( "Path to Session Logs", session.logs.systemLog().asPath )
				
				launchSuccess = true
			}
			catch {
				print( "failed to performInteraction on Session with the following error: \(error)" )
				launchSuccess = false
			}
			
		})
		
		dispatch_group_wait( group, DISPATCH_TIME_FOREVER )

		notificationWaiter.start()
		
		if launchSuccess {
			
			print( "Waiting for app terminated by periodically invoking ps..." )
			waitForApp( app, removedByCheckingwithPSInSession: session )
			
			do {
				try session.terminate()
			}
			catch {
				print( "failed to terminate session with error: \(error)" )
			}
		}
	}
	
	func waitForApp( simulatorApplication: FBSimulatorApplication, removedByCheckingwithPSInSession session: FBSimulatorSession ) {
		let processId: Int = session.state.runningProcessForApplication( simulatorApplication ).processIdentifier
		
		print( "Session -> Application: \(simulatorApplication.name) -> procesId: \(processId)" )
		
		notificationWaiter.wakeUpPeriodicallyForCheckingWithBlock(){
			let result: String = self.resultforCheckingAppWithProcessID( processId )
			let count: Int? = Int( result )
			
			print( "result: \(result)" )
			print( "count: \(count)" )
			
			if let count = count {
				return count == 2
			}
			else {
				return false
			}
		}
	}
	
	func resultforCheckingAppWithProcessID( processID: Int ) -> String {
		let task = FBTaskExecutor.sharedInstance().taskWithLaunchPath( "/bin/bash", arguments: [ "-c", "ps \(processID) | wc -l" ] )
		
		task.startSynchronouslyWithTimeout( 2 )
		return task.stdOut()
	}
}

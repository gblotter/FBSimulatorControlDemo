//
//  DemoFixture.swift
//  SimulatorZ
//
//  Created by Geoffrey Blotter on 11/13/15.
//  Copyright © 2015 LDS Church. All rights reserved.
//

import Foundation
import FBSimulatorControl

class DemoFixture: AnyObject {
	
	private static let appName: String = "SingleViewApp"
	private static let appTestsName: String = "SingleViewAppTests"
	
	private init() {}
	
	static func demoApp( appBuildPath:String ) throws -> FBSimulatorApplication {
		let appBundle: NSBundle? = NSBundle( path: appBuildPath )
		let path: String? = appBundle?.pathForResource( appName, ofType: "app" )
		
		do {
			return try FBSimulatorApplication( path: path! )
		}
		catch let error {
			throw error
		}
	}
	
	static func demoAppLaunchWithTests( appBuildPath: String ) throws -> FBApplicationLaunchConfiguration {
		let demoApp: FBSimulatorApplication
		
		do {
			demoApp = try self.demoApp( appBuildPath )
		}
		catch let error {
			throw error
		}
		
		let appBundle: NSBundle? = NSBundle( path: appBuildPath )
		
		print( "DemoFixture.demoAppLaunchWithTests() path: \(appBuildPath)" )
		
		let appBundlePath: String? = appBundle?.pathForResource( appName, ofType: "app" )
		let appBinaryPath: String? = appBundlePath?.stringByAppendingString( "/\(appName)" )
		let testPath: String? = appBundle?.pathForResource( appTestsName, ofType: "xctest" )
		
		let configuration = FBApplicationLaunchConfiguration( application: demoApp, arguments: [AnyObject](), environment: [ String: AnyObject ]() )
		
		/// This is for the submodule branch: xctest-application-injection
//		var configuration = FBApplicationLaunchConfiguration( application: demoApp, arguments: [AnyObject](), environment: [ String: AnyObject ]() )
//		do {
//			configuration = try configuration.withXCTestBundle( testPath! )
//		}
//		catch {
//			print( "failed with error: \(error)" )
//		}
		
		let insertLibraries: String = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection"

		let xcTestEnvironment: [ String: AnyObject ] = [
			"AppTargetLocation": appBinaryPath!,
			"DYLD_FRAMEWORK_PATH" : "\(appBuildPath):/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks",
			"DYLD_INSERT_LIBRARIES" : insertLibraries,
			"DYLD_LIBRARY_PATH" : "\(appBuildPath):/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks",
			"NSUnbufferedIO" : "YES",
			"OBJC_DISABLE_GC" : "YES",
			"TestBundleLocation" : testPath!,
			"XCInjectBundle": testPath!,
			"XCInjectBundleInto" : appBinaryPath!,
			"XCODE_DBG_XPC_EXCLUSIONS" : "com.apple.dt.xctestSymbolicator",
			"XCTestConfigurationFilePath" : "\(testPath!)/SingleViewAppTests-A0EA4C17-509C-4B76-869E-EFBFC817406D.xctestconfiguration"
		]

		configuration.environment = xcTestEnvironment
//		configuration.environment = [ "DYLD_INSERT_LIBRARIES" : insertLibraries, "XCInjectBundle": testPath!, "XCInjectBundleInto" : appBinaryPath! ]
		
//		configuration.arguments = [ "-XCTest", "All" ]
//		configuration.arguments = [ "-XCTest", "All", insertLibraries ]
		configuration.arguments = [ "-NSTreatUnknownArgumentsAsOpen", "NO", "-ApplePersistenceIgnoreState", "YES" ]
		
		return configuration //.withDiagnosticEnvironment()
	}
}


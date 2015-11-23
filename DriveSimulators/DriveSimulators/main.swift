//
//  main.swift
//  DriveSimulators
//
//  Created by Geoffrey Blotter on 11/16/15.
//  Copyright © 2015 LDS Church. All rights reserved.
//

import Foundation
import FBSimulatorControl

func main( args: [ String ] ) -> Int {

	print( "incoming args: \(args)" )
	
	if args.count > 1 {
		let tempURL: NSURL = NSURL( fileURLWithPath: args[1] )
		let url: NSURL? = NSURL( string: tempURL.absoluteString )
		
		guard let firmUrl = url else {
			print( "Invalid URL path" )
			return 0
		}
		
		print( "url from arg: \(url!)" )
		
		let newPath: String? = firmUrl.URLByResolvingSymlinksInPath?.path
		
		guard let path = newPath else {
			print( "Invalid path" )
			return 0
		}
		
		print( "path from url: \(path)" )
		
		let testRunner: TestRunner = TestRunner()
		
		testRunner.run( appBuildPath: path )
	}
	else {
		print( "Usage: DriveSimulators path_to_SingleViewApp \n\n" )
	}
	
	return 0
}

main( Process.arguments )

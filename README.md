# FBSimulatorControlDemo

This is a sample project to test out the [FBSimulatorControl](https://github.com/facebook/FBSimulatorControl) library. It is patterned off of [azalan/SimCtrlCLI's](https://github.com/azalan/SimCtrlCLI/) project, but is modified to try and illustrate how to run xctest archives from other apps.  It contains an iOS app with a single unit test (see: [SingleViewApp](https://github.com/gblotter/FBSimulatorControlDemo/tree/master/SingleViewApp)) and a Mac app (see: [DriveSimulators](https://github.com/gblotter/FBSimulatorControlDemo/tree/master/DriveSimulators)) which uses the FBSimulatorControl library to create an iOS simulator for the test run, execute the test and after the test execution has been finished, tear down the simulator.

The unit test is not a real test, it just keeps occupied the simulator for 5 seconds.

## Installation

After cloning the repository run [run.sh](https://github.com/gblotter/FBSimulatorControlDemo/blob/master/run.sh). This should compile everything, and after it should run all of the termination notification tests which I can think of.  

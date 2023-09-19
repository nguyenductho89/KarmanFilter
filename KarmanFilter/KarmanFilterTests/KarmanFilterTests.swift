//
//  KarmanFilterTests.swift
//  KarmanFilterTests
//
//  Created by Nguyen Duc Tho on 13/09/2023.
//

import XCTest
@testable import KarmanFilter

final class KarmanFilterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRoomB() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // Example usage: Estimate location based on bin counts of three beacons
        // Example usage: Estimate location based on bin counts of three beacons
        // Example usage: Estimate location based on bin counts of three beacons
        let queryCounts = binRSSIValues(
            beacon1RSSI: [-83.0, -76.0, -77.0].shuffled(),
            beacon2RSSI: [-80.0, -81.0, -81.0].shuffled(),
            beacon3RSSI: [-83.0, -76.0, -77.0].shuffled()
        )

        if let estimatedLocation = estimateLocationFromBins(beaconCounts: queryCounts) {
            print("Estimated Location: \(estimatedLocation)")
        } else {
            print("Location estimation failed.")
        }

    }
    
    func testRoomA() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // Example usage: Estimate location based on bin counts of three beacons
        // Example usage: Estimate location based on bin counts of three beacons
        // Example usage: Estimate location based on bin counts of three beacons
        let queryCounts = binRSSIValues(
            beacon1RSSI: [-65.0, -60.0, -61.0, -65.0, -60.0].shuffled(),
            beacon2RSSI: [-73.0, -75.0, -74.0,-73.0, -75.0].shuffled(),
            beacon3RSSI: [-65.0, -60.0, -61.0].shuffled()
        )

        if let estimatedLocation = estimateLocationFromBins(beaconCounts: queryCounts) {
            print("Estimated Location: \(estimatedLocation)")
        } else {
            print("Location estimation failed.")
        }

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

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

    func test00() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // Example usage: Estimate location based on bin counts of three beacons
        // Example usage: Estimate location based on bin counts of three beacons
        // Example usage: Estimate location based on bin counts of three beacons
        let queryCounts = binRSSIValues(
            beacon1RSSI: [-79.0, -78.0, -78.0, -80.0, -80.0],
            beacon2RSSI: [-71.0, -72.0, -72.0, -73.0, -74.0],
            beacon3RSSI: [-83.0, -82.0, -82.0, -81.0, -81.0]
        )

        if let estimatedLocation = estimateLocationFromBins(beaconCounts: queryCounts) {
            print("Estimated Location: \(estimatedLocation)")
        } else {
            print("Location estimation failed.")
        }

    }
    
    func test01() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // Example usage: Estimate location based on bin counts of three beacons
        // Example usage: Estimate location based on bin counts of three beacons
        // Example usage: Estimate location based on bin counts of three beacons
        let queryCounts = binRSSIValues(
            beacon1RSSI: b1_01,
            beacon2RSSI: b2_01,
            beacon3RSSI: b3_01
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


//thond: beacon1=[-79.0, -78.0, -78.0, -80.0, -80.0] beacon2=[-71.0, -72.0, -72.0, -73.0, -74.0] beacon3=[-83.0, -82.0, -82.0, -81.0, -81.0]
//thond: beacon1=[-79.0, -80.0, -81.0, -80.0, -78.0] beacon2=[-77.0, -76.0, -73.0, -71.0, -71.0] beacon3=[-83.0, -83.0, -83.0, -82.0, -82.0]
//thond: beacon1=[-80.0, -78.0, -80.0, -80.0, -78.0] beacon2=[-71.0, -71.0, -70.0, -71.0, -73.0] beacon3=[-82.0, -82.0, -82.0, -82.0, -82.0]
//thond: beacon1=[-80.0, -78.0, -79.0, -77.0, -79.0] beacon2=[-71.0, -73.0, -73.0, -71.0, -70.0] beacon3=[-82.0, -82.0, -82.0, -82.0, -82.0]
//thond: beacon1=[-79.0, -79.0, -78.0, -78.0, -77.0] beacon2=[-70.0, -71.0, -74.0, -73.0, -74.0] beacon3=[-82.0, -81.0, -82.0, -82.0, -82.0]
//thond: beacon1=[-77.0, -78.0, -79.0, -79.0, -80.0] beacon2=[-74.0, -70.0, -70.0, -74.0, -74.0] beacon3=[-82.0, -82.0, -81.0, -81.0, -81.0]
//thond: beacon1=[-79.0, -80.0, -80.0, -78.0, -77.0] beacon2=[-74.0, -74.0, -73.0, -74.0, -74.0] beacon3=[-81.0, -81.0, -81.0, -81.0, -81.0]
//thond: beacon1=[-77.0, -78.0, -78.0, -79.0, -78.0] beacon2=[-74.0, -74.0, -70.0, -71.0, -74.0] beacon3=[-81.0, -81.0, -82.0, -81.0, -82.0]
//thond: beacon1=[-77.0, -79.0, -81.0, -80.0, -81.0] beacon2=[-74.0, -74.0, -73.0, -74.0, -74.0] beacon3=[-81.0, -82.0, -82.0, -82.0, -82.0]
//thond: beacon1=[-77.0, -80.0, -79.0, -81.0, -80.0] beacon2=[-71.0, -71.0, -71.0, -74.0, -73.0] beacon3=[-82.0, -81.0, -81.0, -81.0, -81.0]
//thond: beacon1=[-80.0, -80.0, -79.0, -78.0, -80.0] beacon2=[-74.0, -71.0, -71.0, -71.0, -71.0] beacon3=[-82.0, -83.0, -82.0, -81.0, -81.0]
//thond: beacon1=[-80.0, -80.0, -81.0, -80.0, -79.0] beacon2=[-71.0, -74.0, -74.0, -70.0, -70.0] beacon3=[-81.0, -81.0, -81.0, -82.0, -82.0]
//thond: beacon1=[-80.0, -80.0, -81.0, -79.0, -80.0] beacon2=[-71.0, -74.0, -74.0, -74.0, -73.0] beacon3=[-82.0, -82.0, -82.0, -82.0, -83.0]
//thond: beacon1=[-80.0, -79.0, -79.0, -81.0, -80.0] beacon2=[-74.0, -74.0, -74.0, -74.0, -70.0] beacon3=[-83.0, -82.0, -82.0, -81.0, -82.0]

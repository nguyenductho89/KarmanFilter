let roomA_b1 = [-68.0, -67.0, -68.0, -68.0, -70.0, -69.0, -69.0, -71.0, -76.0, -75.0, -75.0, -70.0, -70.0, -69.0, -76.0, -76.0, -72.0, -72.0, -76.0]

let roomA_b2 = [-73.0, -73.0, -74.0, -74.0, -74.0, -75.0, -75.0, -74.0, -75.0, -76.0, -75.0, -73.0, -76.0, -75.0, -75.0, -76.0, -76.0, -72.0, -71.0]

let roomB_b1 = [-83.0, -76.0, -77.0, -77.0, -86.0, -86.0, -81.0, -81.0, -77.0, -77.0, -77.0, -76.0, -83.0, -83.0, -83.0, -81.0, -78.0]

let roomB_b2 = [-80.0, -81.0, -81.0, -81.0, -82.0, -82.0, -81.0, -81.0, -80.0, -80.0, -81.0, -81.0, -81.0, -80.0, -81.0, -80.0, -80.0]
//
//let location1 = FingerprintData(
//    location: "Room A",
//    beacon1Counts: binRSSIValues(rssiValues: UserDefaults.standard.value(forKey: "RoomA-b1") as! [Double]),
//    beacon2Counts: binRSSIValues(rssiValues: UserDefaults.standard.value(forKey: "RoomA-b2") as! [Double])
//)
//
//let location2 = FingerprintData(
//    location: "Room B",
//    beacon1Counts: binRSSIValues(rssiValues: UserDefaults.standard.value(forKey: "RoomB-b1") as! [Double]),
//    beacon2Counts: binRSSIValues(rssiValues: UserDefaults.standard.value(forKey: "RoomB-b2") as! [Double])
//)


import Foundation

// Define your signal strength bins
struct RSSIBin {
    let name: String
    let min: Double
    let max: Double
}

let signalStrengthBins: [RSSIBin] = {
    var signalStrengthBins: [RSSIBin] = []
    var minRSSI = -100.0
    while minRSSI < -40.0 {
        let maxRSSI = minRSSI + 5.0
        let binName = "\(Int(minRSSI)) to \(Int(maxRSSI))"
        signalStrengthBins.append(RSSIBin(name: binName, min: minRSSI, max: maxRSSI))
        minRSSI = maxRSSI
    }
    return signalStrengthBins
}()

// Function to bin RSSI values for three beacons
func binRSSIValues(beacon1RSSI: [Double], beacon2RSSI: [Double], beacon3RSSI: [Double]) -> [String: [String: Int]] {
    var binCounts: [String: [String: Int]] = [:]

    // Initialize bin counts for each beacon
    for beacon in ["beacon1", "beacon2", "beacon3"] {
        binCounts[beacon] = [:]
        for bin in signalStrengthBins {
            binCounts[beacon]![bin.name] = 0
        }
    }

    // Count measurements within each bin for beacon1
    for rssi in beacon1RSSI {
        for bin in signalStrengthBins {
            if rssi >= bin.min && rssi < bin.max {
                binCounts["beacon1"]![bin.name]! += 1
            }
        }
    }

    // Count measurements within each bin for beacon2
    for rssi in beacon2RSSI {
        for bin in signalStrengthBins {
            if rssi >= bin.min && rssi < bin.max {
                binCounts["beacon2"]![bin.name]! += 1
            }
        }
    }

    // Count measurements within each bin for beacon3
    for rssi in beacon3RSSI {
        for bin in signalStrengthBins {
            if rssi >= bin.min && rssi < bin.max {
                binCounts["beacon3"]![bin.name]! += 1
            }
        }
    }

    return binCounts
}

// Define a structure to represent fingerprint data for a location
struct FingerprintData {
    let location: String
    let beaconCounts: [String: [String: Int]]
}

// Example fingerprint data for known locations
let beacon1RSSIValuesLocation1 = [-75.0, -85.0, -55.0]
let beacon2RSSIValuesLocation1 = [-65.0, -75.0, -60.0]
let beacon3RSSIValuesLocation1 = [-70.0, -80.0, -90.0]

let location1 = FingerprintData(
    location: "Room A",
    beaconCounts: binRSSIValues(beacon1RSSI: roomA_b1, beacon2RSSI: roomA_b2, beacon3RSSI: roomA_b1)
)

let beacon1RSSIValuesLocation2 = [-90.0, -85.0, -75.0]
let beacon2RSSIValuesLocation2 = [-70.0, -80.0, -55.0]
let beacon3RSSIValuesLocation2 = [-65.0, -70.0, -80.0]

let location2 = FingerprintData(
    location: "Room B",
    beaconCounts: binRSSIValues(beacon1RSSI: roomB_b1, beacon2RSSI: roomB_b2, beacon3RSSI: roomB_b1)
)

// Store the fingerprint data in an array or database
var fingerprintDatabase: [FingerprintData] = [location1, location2]

// Function to estimate location from bin counts of three beacons
func estimateLocationFromBins(beaconCounts: [String: [String: Int]]) -> String? {
    // Implement your location estimation logic here
    // This is where you match the query counts to the stored fingerprint data
    // and determine the estimated location.
    // You can use various techniques like K-nearest neighbors (KNN) or matching.

    // For simplicity, we'll use a basic example here.
    // We'll compare the query counts with known locations in the database
    // and choose the location with the smallest Euclidean distance.
    var bestMatchLocation: String?
    var bestMatchDistance = Double.infinity

    for data in fingerprintDatabase {
        var distance = 0.0

        for beacon in ["beacon1", "beacon2", "beacon3"] {
            for bin in signalStrengthBins {
                let queryCount = Double(beaconCounts[beacon]?[bin.name] ?? 0)
                let dbCount = Double(data.beaconCounts[beacon]?[bin.name] ?? 0)
                let countDifference = queryCount - dbCount
                distance += countDifference * countDifference
            }
        }

        if distance < bestMatchDistance {
            bestMatchDistance = distance
            bestMatchLocation = data.location
        }
    }

    return bestMatchLocation
}



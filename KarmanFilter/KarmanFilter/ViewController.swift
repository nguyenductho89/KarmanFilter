import CoreLocation
import UIKit
// Define a struct to represent a 1D Kalman filter
struct KalmanFilter {
    var state: Double     // State variable (position)
    var covariance: Double // Covariance

    // Initialize the Kalman filter with an initial state and covariance
    init(initialState: Double, initialCovariance: Double) {
        state = initialState
        covariance = initialCovariance
    }

    // Update the Kalman filter with a new measurement
    mutating func update(measurement: Double, measurementNoise: Double, processNoise: Double) {
        // Prediction Step

        // Predict the next state based on the current state (state)
        let prediction = state

        // Predict the covariance of the next state
        let predictionCovariance = covariance + processNoise

        // Update Step

        // Calculate the Kalman Gain, which determines how much weight to give to the measurement
        let kalmanGain = predictionCovariance / (predictionCovariance + measurementNoise)

        // Update the state estimate using the Kalman Gain and the measurement
        state = prediction + kalmanGain * (measurement - prediction)

        // Update the covariance estimate
        covariance = (1 - kalmanGain) * predictionCovariance
    }
}

import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var kalmanFilters = [UUID: KalmanFilter]() // Keep a Kalman filter for each beacon based on UUID

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: UUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!))
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            // Identify the Kalman filter based on the beacon's UUID
            guard var kalmanFilter = kalmanFilters[beacon.uuid] else {
                // If a filter for this UUID doesn't exist, create one with initial values
                let initialRSSI = Double(beacon.rssi)
                let initialCovariance = -59.0
                // Adjust as needed
                let kalmanFilter = KalmanFilter(initialState: initialRSSI, initialCovariance: initialCovariance)
                kalmanFilters[beacon.uuid] = kalmanFilter
                continue
            }

            // Update the Kalman filter with the latest RSSI measurement
            let measurementNoise = 1.0 // Adjust as needed
            let processNoise = 0.1 // Adjust as needed
            kalmanFilter.update(measurement: Double(beacon.rssi), measurementNoise: measurementNoise, processNoise: processNoise)

            // Get the estimated RSSI from the Kalman filter
            let estimatedRSSI = kalmanFilter.state

            // Calculate the Mean Absolute Error (MAE) for this beacon
            let mae = abs(estimatedRSSI - Double(beacon.rssi))

            // Handle the estimated RSSI value as needed (e.g., use it for positioning or further calculations)
            print("Beacon UUID: \(beacon.uuid.uuidString)")
            print("Estimated RSSI: \(estimatedRSSI) real=\(beacon.rssi) MAE=\(mae)")
            print("------------------------")
        }
    }
}

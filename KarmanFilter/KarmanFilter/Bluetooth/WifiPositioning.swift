//
//  WifiPositioning.swift
//  KarmanFilter
//
//  Created by Nguyen Duc Tho on 13/09/2023.
//

import CoreLocation

class IndoorPositioningWithWiFi: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            // Access WiFi signal strength data and estimate indoor position here
           // print("Estimated indoor position using WiFi: \(currentLocation.coordinate)")
        }
    }
}



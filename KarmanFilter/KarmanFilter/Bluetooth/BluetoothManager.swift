//
//  BluetoothManager.swift
//  KarmanFilter
//
//  Created by Nguyen Duc Tho on 13/09/2023.
//

import CoreBluetooth
import os
class IndoorPositioningWithBluetooth: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Scan for nearby Bluetooth beacons (iBeacons) here
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning for Bluetooth beacons...")
        } else {
            print("Bluetooth is not available or powered off.")
        }
    }
    
    func estimateDistanceFromRSSI(RSSI: Int, txPower: Int) -> Double {
        let pathLossExponent = 10.0 // Assuming a path loss exponent of 2 (free-space conditions)
        let referenceDistance = 1.0 // Reference distance (1 meter)
        
        let ratio = Double(txPower - RSSI) / (10.0 * pathLossExponent)
        let estimatedDistance = pow(10.0, ratio) * referenceDistance
        
        return estimatedDistance
    }


    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let peripheralDescription = peripheral.description
        var distance = ""
        // Extract the transmitted power (txPower) from advertisementData
        if let txPowerLevel = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber {
            let txPower = txPowerLevel.intValue
            
            // Calculate the distance using the RSSI and extracted txPower
            let distanceVal = estimateDistanceFromRSSI(RSSI: RSSI.intValue, txPower: txPower)
            distance = "\(distanceVal)"
        } 
//        else {
//            let txPower = -59
//            
//            let distanceVal = estimateDistanceFromRSSI(RSSI: RSSI.intValue, txPower: txPower)
//            distance = "\(distanceVal)"
//        }
        if !(peripheral.name ?? "").isEmpty {
            
            
            
            os_log("Name Discovered peripheral: peripheralDescription=%@ RSSI=%d distance=%@", log: .default, type: .error, peripheralDescription, RSSI.intValue, distance)

        } else {
            os_log("Discovered peripheral: peripheralDescription=%@ RSSI=%d distance=%@", log: .default, type: .error, peripheralDescription, RSSI.intValue, distance)
        }
        
    }

}




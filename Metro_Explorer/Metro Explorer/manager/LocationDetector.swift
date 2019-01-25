//
//  LocationDetector.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/21/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationDetectorDelegate {
    func locationDetected(latitude: Double, longitude: Double)
    func locationNotDetected(reason: LocationDetector.FailureReason) //no GPS/network signal for 10 seconds (timeout) OR no permission
}

class LocationDetector: NSObject {
    var waitTimer: Timer!// init a timer
    
    enum FailureReason: String {
        case noGPS = "No GPS" //give up
        case timeout = "network signal for 10 seconds (timeout) " //allow the user to try again
        case noPermission = "no permission" //give up
        case notCompleted = "not completed"//give up
        
    }
    
    let locationManager = CLLocationManager()
    
    var delegate: LocationDetectorDelegate?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    @objc func locationTimeOut(){//time out && stop update location
        locationManager.stopUpdatingLocation()
        delegate?.locationNotDetected(reason: .timeout)
    }
    
    func findLocation() {
        let permissionStatus = CLLocationManager.authorizationStatus()
        
        switch(permissionStatus) {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            delegate?.locationNotDetected(reason: .noGPS)
        case .denied:
            delegate?.locationNotDetected(reason: .noPermission)
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            waitTimer = Timer.scheduledTimer (timeInterval: 10.0, target: self, selector: #selector(locationTimeOut), userInfo:nil,repeats: false)//set timer
            locationManager.requestLocation()
        }
    }

}

extension LocationDetector: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //do something with the location
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            waitTimer?.invalidate()
            delegate?.locationDetected(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //handle the error
        print(error.localizedDescription)
        delegate?.locationNotDetected(reason: .notCompleted)
    }
    
    //this gets called after user accepts OR denies permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //handle this
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            
        }
        else {
            delegate?.locationNotDetected(reason: .noPermission)
        }
    }
    
}

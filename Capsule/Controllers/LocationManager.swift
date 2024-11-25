//
//  LocationManager.swift
//  Cours_13_Map_GPS
//
//  Created by prof005 on 2024-11-22.
//

import Foundation
import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate{
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    var location: CLLocationCoordinate2D?
    var status: CLAuthorizationStatus?
    
    override init(){
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.requestAuthorization()
        
    }
    
    func requestAuthorization(){
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        self.status = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
        else{
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.location = locations.first?.coordinate
    }
    
    
}

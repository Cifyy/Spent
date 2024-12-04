//
//  LocationManager.swift
//  spent1
//
//  Created by Jakub Majka on 19/10/24.
//

import CoreLocation

enum locationError: Error{
    case locationServicesNotEnabled, noLocationPermission, unknownLocationError
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var locationPermission = true
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func checkAuthorization() async throws -> CLLocationCoordinate2D{
        
        if !CLLocationManager.locationServicesEnabled(){
            throw locationError.locationServicesNotEnabled
        }
        
        switch self.manager.authorizationStatus{
            
            case .denied, .notDetermined, .restricted:
                throw locationError.noLocationPermission
            
            case .authorizedAlways, .authorizedWhenInUse:
                guard let location = manager.location?.coordinate else {
                    throw locationError.unknownLocationError
                }
                return location

            @unknown default:
                break
                
        }
        throw locationError.unknownLocationError
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        if manager.authorizationStatus == .authorizedWhenInUse{ locationPermission = true }
        else{ locationPermission = false }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(String(describing: error))
    }
}



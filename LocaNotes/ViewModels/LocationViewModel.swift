//
//  LocationViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 2/28/21.
//

import Foundation
import Combine
import CoreLocation

class LocationViewModel: NSObject, ObservableObject {
    
    @Published var userLatitude: Double = 0
    @Published var userLongitude: Double = 0
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLatitude = location.coordinate.latitude
        userLongitude = location.coordinate.longitude
        print(location)
        
        let coordinate = ["latitude": userLatitude, "longitude": userLongitude]
        
        // broadcast coordinate update
        NotificationCenter.default.post(name: .userCoordinateDidUpdate, object: self, userInfo: coordinate)
    }
}

extension Notification.Name {
    static let userCoordinateDidUpdate = Notification.Name("userCoordinateDidUpdate")
}

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
    
    // the user's latitude and longitude
    @Published var userLatitude: Double = 0
    @Published var userLongitude: Double = 0
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.requestWhenInUseAuthorization()
        
        // request the user to let the app always use their location
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.startUpdatingLocation()
    }
    
    /**
     Returns the distance in meters between the user and a note's GPS coordinates.
     - Parameters:
        - latitude: the *latitude* of a note
        - longitude: the *longitude* of a note
     - Returns: the distance in meters between the user and a note's GPS coordinates
     */
    func getDistanceBetweenNoteAndUser(latitude: Double, longitude: Double) -> Double {
        // turn the user' lat/long into a coordinate
        let userCoordinate = CLLocation(latitude: userLatitude, longitude: userLongitude)
        
        // turn the note's lat/long into a cooridnate
        let noteCoordinate = CLLocation(latitude: latitude, longitude: longitude)
        print("user: lat: \(userLatitude) long: \(userLongitude)")
        print("note: lat: \(latitude) long: \(longitude)")
//        print(userCoordinate)
//        print(noteCoordinate)
        
        // compute distance
        let distanceInMeters = userCoordinate.distance(from: noteCoordinate)
        
        print(distanceInMeters)
        
        return distanceInMeters.magnitude
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    
    /**
     Callback function that gets called when the user's location updates
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        // update the user's latitude and longitude
        userLatitude = location.coordinate.latitude
        userLongitude = location.coordinate.longitude
        print(location)
        
        // make a container that the lat/long and broadcast the update to listeners
        let coordinate = ["latitude": userLatitude, "longitude": userLongitude]
        NotificationCenter.default.post(name: .userCoordinateDidUpdate, object: self, userInfo: coordinate)
    }
}

extension Notification.Name {
    static let userCoordinateDidUpdate = Notification.Name("userCoordinateDidUpdate")
}

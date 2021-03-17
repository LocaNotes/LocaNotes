//
//  MapView.swift
//  LocaNotes
//
//  Created by Elijah Monzon on 3/17/21.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable{
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context){
        print("Updating Location")
        if annotations.count != view.annotations.count{
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView){
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView){
            parent.centerCoordinate = mapView.centerCoordinate
            
        }
    }
}

extension MKPointAnnotation{
    static var example: MKPointAnnotation{
        let annotation = MKPointAnnotation()
        annotation.title = "title"
        annotation.subtitle = "sub"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 39, longitude: 0.13)
        return annotation
    }
}

struct MapView_Previews: PreviewProvider{
    static var previews: some View{
        MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate),
                annotations: [MKPointAnnotation.example])
    }
}


//
//  MapView.swift
//  LocaNotes
//
//  Created by Elijah Monzon on 3/17/21.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable{
    @Binding var centerCoordinate: CLLocationCoordinate2D //center coordinate
    @Binding var selectedAnno: MKPointAnnotation? //selected annotation
    @Binding var showingDetails: Bool //whether annotation is being viewed
    var annotations: [MKPointAnnotation]
    

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter?.includes(MKPointOfInterestCategory.airport)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.setRegion(MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 0, longitudinalMeters: 0), animated: true)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context){
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
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? MKPointAnnotation else {return}
            parent.selectedAnno = placemark
            parent.showingDetails = true
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
        MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate),selectedAnno: .constant(MKPointAnnotation.example),showingDetails: .constant(false),annotations: [MKPointAnnotation.example])
    }
}


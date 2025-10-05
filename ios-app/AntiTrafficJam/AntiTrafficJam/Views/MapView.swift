import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let events: [TrafficEvent]
    let userLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        if let location = userLocation {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
            mapView.setRegion(region, animated: false)
        }

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)

        let annotations = events.map { event -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = event.coordinate
            annotation.title = event.type.displayName
            return annotation
        }

        mapView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(events: events)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let events: [TrafficEvent]

        init(events: [TrafficEvent]) {
            self.events = events
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }

            let identifier = "EventAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            if let markerView = annotationView as? MKMarkerAnnotationView {
                if let event = events.first(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
                    markerView.glyphImage = UIImage(systemName: event.type.icon)
                    switch event.type.color {
                    case "red":
                        markerView.markerTintColor = .systemRed
                    case "orange":
                        markerView.markerTintColor = .systemOrange
                    case "yellow":
                        markerView.markerTintColor = .systemYellow
                    case "blue":
                        markerView.markerTintColor = .systemBlue
                    default:
                        markerView.markerTintColor = .systemGray
                    }
                }
            }

            return annotationView
        }
    }
}

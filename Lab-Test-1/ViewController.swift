//
//  ViewController.swift
//  Lab-Test-1
//
//  Created by Macbook on 5/14/21.
//

import UIKit
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var dist1: UILabel!
    @IBOutlet weak var dist2: UILabel!
    @IBOutlet weak var dist3: UILabel!
    
    var locationManager = CLLocationManager()
    
    // destination variable
    var destination: CLLocationCoordinate2D!
    
    var testdestinationLat = 0.0
    var testdestinationLong = 0.0
    
    var locations = [CLLocationCoordinate2D]()
    
    var lato = 0.0
    var longo = 0.0
    var touchCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // we assign the delegate property of the location manager to be this class
        locationManager.delegate = self
        
        // we define the accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // rquest for the permission to access the location
        locationManager.requestWhenInUseAuthorization()
         
        // start updating the location
        locationManager.startUpdatingLocation()
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotattion))
        mapView.addGestureRecognizer(uilpgr)
        
        addDoubleTap()
        addSingleTap()
        // giving the delegate of MKMapViewDelegate to this class
        mapView.delegate = self
       
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        lato = latitude
        longo = longitude
        
        
        displayLocation(latitude: latitude, longitude: longitude, title: "My location", subtitle: "you are here")
    }
    
    
  
    
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        mapView.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addLongPressAnnotattion(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // add annotation for the coordinatet
        let annotation = MKPointAnnotation()
        annotation.title = "My favourite"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        
        
    }
    
    //MARK: - double tap function
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        
        
        touchCount += 1
        // add annotation
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        
        
        if(touchCount == 4){
            
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations)
                        
            annotation.title = "A"
            annotation.coordinate = locations[0]
            mapView.addAnnotation(annotation)
            locations.removeAll()
            locations.append(annotation.coordinate)
            touchCount = 1
            
        }
        
        else{
            
        if(touchCount == 1){
        annotation.title = "A"
            
        }
        else if(touchCount == 2){
            
            
            annotation.title = "B"
        }
        
        else if(touchCount == 3){
            
            annotation.title = "C"
        }
       
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        destination = coordinate
        
        locations.append(destination)
        print(locations)
        

        addPolygon()
            

        if(touchCount == 3){
            let coordinate1 = CLLocation(latitude: locations[0].latitude, longitude: locations[0].longitude)

            let coordinate2 = CLLocation(latitude: locations[1].latitude, longitude: locations[1].longitude)
            
            let coordinate3 = CLLocation(latitude: locations[2].latitude, longitude: locations[2].longitude)

            let distanceFromAtoB = (coordinate1.distance(from: coordinate2))
            let distancefromBtoC = (coordinate2.distance(from: coordinate3))
            let distancefromCtoA = (coordinate3.distance(from: coordinate1))
            
            let distanceFromAtoBKms =  String(format: "%.2f", (distanceFromAtoB/1000))
            let distancefromBtoCKms =  String(format: "%.2f", (distancefromBtoC/1000))
            let distancefromCtoAKms =  String(format: "%.2f", (distancefromCtoA/1000))
            
            dist1.text = distanceFromAtoBKms+"  kms"
            dist2.text = distancefromBtoCKms+"  kms"
            dist3.text = distancefromCtoAKms+"  kms"
        }
            
        removePin(des:destination)
        
        }
       
    }
    

    //MARK: - polygon method
    func addPolygon() {
        let coordinates = locations.map {$0}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
    }
    
    func removePin(des:CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()

        for loc in locations {
            
            if(loc.latitude == des.latitude ){
                annotation.coordinate = des
                
                mapView.removeAnnotation(annotation)
            }
            }
            
        
    }
    
    @IBAction func drawRoute(_ sender: Any) {
        
        mapView.removeOverlays(mapView.overlays)
        
        let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        
        for desti in locations{
            
        let destinationPlaceMark = MKPlacemark(coordinate: desti)
        
            
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        
        
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            

            
          
        }
    }
    
    
   
    }
    func addSingleTap() {
        let Tap = UITapGestureRecognizer(target: self, action: #selector(dropsinglePin))
        Tap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(Tap)
        
    }
    
    @objc func dropsinglePin(sender: UITapGestureRecognizer) {
        
        
        // add annotation
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        testdestinationLat = coordinate.latitude
        testdestinationLong = coordinate.longitude
        
        
        print("single tap")
        
       
    }
}

extension ViewController: MKMapViewDelegate {
    
        //MARK: - viewFor annotation method
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

            if annotation is MKUserLocation {
                return nil
            }

            switch annotation.title {
            case "My location":
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
                annotationView.markerTintColor = UIColor.blue
                return annotationView
            case "A":
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                annotationView.animatesDrop = true
                annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
                
            case "B":
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                annotationView.animatesDrop = true
                annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
                
            case "C":
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                annotationView.animatesDrop = true
                annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
                
            case "My favourite":
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
                annotationView.image = UIImage(named: "ic_place_2x")
               
                return annotationView
            default:
                return nil
            }
        }

//        //MARK: - callout accessory control tapped
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {



            let coordinate1Lat = lato

            let coordinate1Long = longo

            let coordinate1 = CLLocation(latitude: coordinate1Lat, longitude: coordinate1Long)

            let coordinate2 = CLLocation(latitude: testdestinationLat, longitude: testdestinationLong)

            let distanceInMeters = (coordinate1.distance(from: coordinate2))

            let distanceInKms =  String(distanceInMeters/1000)

            let alertController = UIAlertController(title: "Distance from source", message: "distance is "+distanceInKms+"Km", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    
    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}


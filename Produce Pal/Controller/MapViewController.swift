//
//  ViewController.swift
//  Produce Pal
//
//  Created by Noah Woodward on 1/29/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate  {
    
    var locationManager = CLLocationManager()
    var markets: [Market]?
    
    
    var marketMap: MKMapView {
        let mapView = MKMapView()
        mapView.mapType = MKMapType.standard
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.center = view.center
        return mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MarketService.getMarkets(zip: "94102") { (result) in
            switch result{
            case .success(let loadedMarkets):
                print(loadedMarkets)
                self.markets = loadedMarkets
            case .failure(let _):
                let alertVC = UIAlertController(title: "Couldent load markets", message: "Try again later, we are sorry", preferredStyle: UIAlertController.Style.alert)
                self.present(alertVC, animated: true)
            }
            self.setupMap()
            self.showLocation()
            self.loadAnnotations()
        }
        
        
    }
    
    private func setupMap() {
        let mapView = marketMap
        view.addSubview(mapView)
        
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        
    }
    
    private func showLocation() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        

    }
    
    func loadData(zip: String){
        
        
    }
    
    func loadAnnotations(){
//        print(self.markets)
//        let geocoder = CLGeocoder()
//        guard let unwrappedMarkets = markets else {return}
//        let dpg = DispatchGroup()
//        for item in unwrappedMarkets{
//            dpg.enter()
//            guard let location = item.location else { continue }
//            geocoder.geocodeAddressString(location) { [weak self] (placemarks, err) in
//                print("Before Dispatch group leave")
//                if let placemark = placemarks?.first, let location = placemark.location {
//
//                    let mark = MKPlacemark(placemark: placemark)
//                    print("Mark: \(mark)")
//                    self?.marketMap.addAnnotation(mark)
//                    dpg.leave()
//                }
//            }
//
//        }
//        dpg.notify(queue: .main) {
//            print("Finished!")
//        }
        
        guard let unwrappedMarkets = markets else {return}
        let geocoder = CLGeocoder()

        
        geocoder.geocodeAddressString(unwrappedMarkets[0].location!) { [weak self] (placemarks, err) in
            if let placemark = placemarks?.first, let location = placemark.location {
                location.coordinate.latitude
                print("Location: \(location)")
                let anno = MKPointAnnotation()
                anno.coordinate = location.coordinate
//                let mark = MKPlacemark(placemark: placemark)
//                print("Mark: \(mark)")
                print("anno: \(anno)")
                anno.title = "Please work"
                self?.marketMap.addAnnotation(anno)
                self?.marketMap.showAnnotations([anno], animated: true)
                print(self?.marketMap.annotations)

            }
        }
        
        
        
    }
}


extension MapViewController : MKMapViewDelegate{
    //Adjusting the zoom
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        var region = MKCoordinateRegion()
        region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05); //Zoom distance
        let coordinate = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude:  userLocation.coordinate.longitude)
        region.center = coordinate
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return MKAnnotationView(annotation: annotation, reuseIdentifier: "hello")
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        debugPrint("startLocating")
    }
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        debugPrint("stopLocating")
    }
}

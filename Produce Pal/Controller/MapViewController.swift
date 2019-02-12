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
    
    
    private let marketMap: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.setUserTrackingMode(.follow, animated: true)
        return mapView
    }()
    
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
        view.addSubview(marketMap)
        
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        marketMap.center = view.center
//        marketMap.delegate = self
        
        marketMap.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        
    }
    
    private func showLocation() {
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1200, longitudinalMeters: 1200)
            marketMap.setRegion(viewRegion, animated: false)
        }
        
        self.locationManager = locationManager
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func loadData(zip: String){
        
        
    }
    
    func loadAnnotations(){
        print(self.markets)
        guard let unwrappedMarkets = markets else {return}
        let dpg = DispatchGroup()
        for item in unwrappedMarkets{
            dpg.enter()
            guard let location = item.location else { continue }
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(location) { [weak self] (placemarks, err) in
                print("Before Dispatch group leave")
                if let placemark = placemarks?.first, let location = placemark.location {

                    let mark = MKPlacemark(placemark: placemark)
                    print("Mark: \(mark)")
                    self?.marketMap.addAnnotation(mark)
                    dpg.leave()
                }
            }

        }
        dpg.notify(queue: .main) {
            print("Finished!")
        }

//        guard let unwrappedMarkets = markets else {return}
//        let geocoder = CLGeocoder()

        
//        geocoder.geocodeAddressString(unwrappedMarkets[0].location!) { [weak self] (placemarks, err) in
//            if let placemark = placemarks?.first, let location = placemark.location {
//                location.coordinate.latitude
//                print("Location: \(location)")
//                let anno = MKPointAnnotation()
//                anno.coordinate = location.coordinate
////                let mark = MKPlacemark(placemark: placemark)
////                print("Mark: \(mark)")
//                print("anno: \(anno)")
//                anno.title = "Please work"
//                self?.marketMap.addAnnotation(anno)
////                self?.marketMap.showAnnotations([anno], animated: true)
//                print(self?.marketMap.annotations)
//
//            }
//        }
        
        
        
    }
}

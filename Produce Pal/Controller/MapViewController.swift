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
    var userZIP: String?
    
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
    
    private let marketDetail: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var previewAllDetails: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previewTextDetails,moreInfoButton])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var previewTextDetails: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previewTitleDetails,previewHoursDetails])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let previewTitleDetails: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Market Title"
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let previewHoursDetails: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "8:00AM - 1:00PM"
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View More", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18)
        button.layer.cornerRadius = 10
        button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(pushToMarketDetails), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func pushToMarketDetails(sender: UIButton) {
        let marketDetailViewController = MarketDetailsViewController()
        self.present(marketDetailViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupMap()
        self.showLocation()
        self.setupMarketPreview()

        
    }
    
    private func setupMap() {
        view.addSubview(marketMap)
        
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        marketMap.center = view.center
        marketMap.delegate = self
        
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
            print(userLocation)
            marketMap.setRegion(viewRegion, animated: false)
            let geoCoder = CLGeocoder()
            let lat = userLocation.latitude
            let lon = userLocation.longitude
            let location = CLLocation(latitude: lat, longitude: lon)
             let dpg = DispatchGroup()
            dpg.enter()
            geoCoder.reverseGeocodeLocation(location) { (placemarks, err) in
                dpg.leave()
                if let error = err {
                    let alertVC = UIAlertController(title: "Unable to get market ZIP", message: err?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
                        return
                    }
                    alertVC.addAction(cancelAction)
                    self.present(alertVC, animated: true)
                }
                
                var placeMark: CLPlacemark?
                placeMark = placemarks?[0]
               
                if let zip = placeMark?.addressDictionary?["ZIP"] as? String {
                    self.loadData(zip: zip)
                }
            }
            
        }
        

        
        self.locationManager = locationManager
        
        
        		
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    private func loadData(zip: String){
        
        MarketService.getMarkets(zip: zip) { (result) in
            switch result{
            case .success(let loadedMarkets):
                self.markets = loadedMarkets
            case .failure(let _):
                let alertVC = UIAlertController(title: "Couldent load markets", message: "Try again later, we are sorry", preferredStyle: UIAlertController.Style.alert)
                self.present(alertVC, animated: true)
            }
            
            self.loadAnnotations()
        }
        
    }
    
    func loadAnnotations(){
        guard let unwrappedMarkets = markets else {return}
        if unwrappedMarkets.count == 0 {
            let alertVC = UIAlertController(title: "No Markets", message: "It looks like there are no markets to display, please try again later", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
                return
            }
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true)
        }

        let dpg = DispatchGroup()
        for item in unwrappedMarkets{
            dpg.enter()
            guard let location = item.location else { continue }
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(location) { [weak self] (placemarks, err) in
                if let placemark = placemarks?.first, let location = placemark.location {
                    var marketName = item.name
                    for i in 0..<3 {
                        marketName.remove(at: marketName.startIndex)
                    }
                    let mark = MKPlacemark(placemark: placemark)
                    let annotation = MKPointAnnotation()
                    annotation.title = marketName
                    annotation.coordinate = location.coordinate
                    self?.marketMap.addAnnotation(annotation)
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
    
    private func setupMarketPreview() {
        marketMap.addSubview(marketDetail)
        marketDetail.addSubview(previewAllDetails)
        
        NSLayoutConstraint.activate([
            marketDetail.topAnchor.constraint(equalTo: marketMap.topAnchor, constant: 720),
            marketDetail.leadingAnchor.constraint(equalTo: marketMap.leadingAnchor, constant: 20),
            marketDetail.trailingAnchor.constraint(equalTo: marketMap.trailingAnchor, constant: -20),
            marketDetail.bottomAnchor.constraint(equalTo: marketMap.bottomAnchor, constant: -50),
            
            previewAllDetails.topAnchor.constraint(equalTo: marketDetail.topAnchor),
            previewAllDetails.leadingAnchor.constraint(equalTo: marketDetail.leadingAnchor, constant: 25),
            previewAllDetails.trailingAnchor.constraint(equalTo: marketDetail.trailingAnchor, constant: -25),
            previewAllDetails.bottomAnchor.constraint(equalTo: marketDetail.bottomAnchor)
            ])
        
    }
    
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        marketDetail.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        marketDetail.isHidden = true
    }
}

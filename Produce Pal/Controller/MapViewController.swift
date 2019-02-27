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
    private var selectedMarket: Market?
    
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
    
    private let marketDetailView: UIControl = {
        let view = UIControl()
        view.backgroundColor = .white
        view.layer.cornerRadius = 7
        view.isHidden = true
        view.addTarget(self, action: #selector(pushToMarketDetails), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let previewMarketImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "Market")
        image.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        image.layer.cornerRadius = 7
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var previewDetails: UIStackView = {
        let previewStackView = UIStackView(arrangedSubviews: [previewTitleDetails, previewSeasonalDetails])
        previewStackView.alignment = .fill
        previewStackView.distribution = .fillEqually
        previewStackView.axis = .vertical
        previewStackView.spacing = 0
        previewStackView.isUserInteractionEnabled = false
        previewStackView.translatesAutoresizingMaskIntoConstraints = false
        return previewStackView
    }()
    
    private let previewTitleDetails: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Market Title"
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let previewSeasonalDetails: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Year Round"
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc private func pushToMarketDetails(sender: UIButton) {
        guard let selected = selectedMarket else {fatalError("No Selected Market")}
        
        let marketDetailViewController = MarketDetailsViewController()
        marketDetailViewController.selectedMarket = selected
        self.present(marketDetailViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupMap()
        self.sanitizeMarkets()
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
    
    private func sanitizeMarkets(){
        
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
                for i in 0..<self.markets!.count{
                    var marketName = self.markets![i].name
                    for _ in 0..<3 {
                        marketName.remove(at: marketName.startIndex)
                    }
                    
                    self.markets![i].name = marketName
                }
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
        marketMap.addSubview(marketDetailView)
        marketDetailView.addSubview(previewDetails)
        marketDetailView.addSubview(previewMarketImage)
        
        
        NSLayoutConstraint.activate([
            
            marketDetailView.heightAnchor.constraint(equalTo: marketMap.heightAnchor, multiplier: 0.13),
            marketDetailView.leadingAnchor.constraint(equalTo: marketMap.leadingAnchor, constant: 20),
            marketDetailView.trailingAnchor.constraint(equalTo: marketMap.trailingAnchor, constant: -20),
            marketDetailView.bottomAnchor.constraint(equalTo: marketMap.bottomAnchor, constant: -50),
            
            previewDetails.heightAnchor.constraint(equalTo: marketDetailView.heightAnchor, multiplier: 0.65),
            previewDetails.leadingAnchor.constraint(equalTo: previewMarketImage.trailingAnchor, constant: 20),
            previewDetails.trailingAnchor.constraint(equalTo: marketDetailView.trailingAnchor, constant: -20),
            previewDetails.bottomAnchor.constraint(equalTo: marketDetailView.bottomAnchor, constant: -20),
            
            previewMarketImage.heightAnchor.constraint(equalTo: marketDetailView.heightAnchor),
            previewMarketImage.leadingAnchor.constraint(equalTo: marketDetailView.leadingAnchor),
            previewMarketImage.widthAnchor.constraint(equalTo: marketDetailView.widthAnchor, multiplier: 0.32)
            
            ])
        
    }
    
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        marketDetailView.isHidden = false
        let selected = mapView.selectedAnnotations
        guard let marketsUnwrapped = self.markets else {fatalError("Really thinking this case is impossible")}
        let filteredMarket = marketsUnwrapped.filter {$0.name == selected[0].title }
        self.selectedMarket = filteredMarket[0]
        
        let timeString = filteredMarket[0].time
        let cleanTimeLabel = timeString?.replace(string: "<br>", replacement: " ")
        
        let titleString = filteredMarket[0].name
        let cleanTitleLabel = titleString.trimmingCharacters(in: .whitespacesAndNewlines)

        previewTitleDetails.text = cleanTitleLabel
        previewSeasonalDetails.text = cleanTimeLabel
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        marketDetailView.isHidden = true
        
    }
    

}

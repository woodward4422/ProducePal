//
//  ViewController.swift
//  Produce Pal
//
//  Created by Noah Woodward on 1/29/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var markets = [Market]()
    
    var marketMap: MKMapView {
        let mapView = MKMapView()
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.center = view.center
        return mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupMap()
        MarketService.getMarkets(zip: "94102") { (result) in
            switch result {
            case .success(let idMarkets):
                for element in idMarkets{
                    MarketService.getMarketInformation(market: element, completion: { (result) in
                        switch result{
                        case .success(let market):
                            self.markets.append(market)
                        case .failure:
                            let alertVC = UIAlertController(title: "Unable to load markets", message: "Unable to retrieve Markets within this area", preferredStyle: .alert)
                            self.present(alertVC, animated: true)
                        }
                        
                    })
                }
                print("Markets: \(self.markets)")
            case .failure(let error):
                print("Error: \(error)")
                let alertVC = UIAlertController(title: "Unable to load markets", message: "Unable to retrieve Markets within this area", preferredStyle: .alert)
                self.present(alertVC, animated: true)
            }
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
}

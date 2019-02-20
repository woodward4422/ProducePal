//
//  MarketDetailsViewController.swift
//  Produce Pal
//
//  Created by Ryan Nguyen on 2/10/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import UIKit

class MarketDetailsViewController: UIViewController {
    
    // MARK: - Labels for the Market Details
    
    private lazy var marketDetailStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dismissButton,marketTitle, addressLabel, seasonAndHourTitle, productsTitle])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 50
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        button.layer.cornerRadius = 10
        button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(dismissToMap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let marketTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Market Title"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 25)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productsTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Products Offer"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Labels for Address/Distance/Button
    
    private lazy var addressDistanceDirection: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addressDistance,directionIcon])
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addressDistance: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addressLabel,distanceLabel])
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.text = "3595 California St.\nSan Francisco, CA 94118"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "0.4mi"
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 10)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directionIcon: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Direction Icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    
    
    // MARK: - Labels for the seasonAndHour section
    
    private lazy var seasonHourDayStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [seasonLabel,hoursAndDayLabel])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var hoursAndDayLabel: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayInfoLabel, hoursLabel])
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let seasonAndHourTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Seasons and Hours"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let seasonLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "June - October"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hoursLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "8:00AM - 1:00PM"
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dayInfoLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Sundays"
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return label
    }()
    
    @objc private func dismissToMap(sender: UIButton) {
//        let marketViewController = MapViewController()
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupLayout()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    private func setupLayout() {
        let informationContainerView = UIView()
        informationContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(informationContainerView)
        
        informationContainerView.addSubview(marketDetailStackView)
        informationContainerView.addSubview(seasonHourDayStackView)
        informationContainerView.addSubview(addressDistanceDirection)
        
        NSLayoutConstraint.activate([
            
            informationContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            informationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            informationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            informationContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            addressDistanceDirection.topAnchor.constraint(equalTo: marketTitle.bottomAnchor),
            addressDistanceDirection.leadingAnchor.constraint(equalTo: marketTitle.leadingAnchor),
            addressDistanceDirection.trailingAnchor.constraint(equalTo: marketTitle.trailingAnchor),
            
            
            
            marketDetailStackView.topAnchor.constraint(equalTo: informationContainerView.topAnchor, constant: 20),
            marketDetailStackView.leadingAnchor.constraint(equalTo: informationContainerView.leadingAnchor, constant: 20),
            marketDetailStackView.trailingAnchor.constraint(equalTo: informationContainerView.trailingAnchor),
            marketDetailStackView.bottomAnchor.constraint(equalTo: informationContainerView.bottomAnchor),
            
            seasonHourDayStackView.topAnchor.constraint(equalTo: seasonAndHourTitle.topAnchor, constant: 65),
            seasonHourDayStackView.leadingAnchor.constraint(equalTo: seasonAndHourTitle.leadingAnchor),
            seasonHourDayStackView.trailingAnchor.constraint(equalTo: seasonAndHourTitle.trailingAnchor),
            seasonHourDayStackView.heightAnchor.constraint(equalTo: seasonAndHourTitle.heightAnchor, multiplier: 0.6)
            
            ])
    }
    
}

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
    
    var selectedMarket: Market?
    
    private lazy var marketDetailStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [marketTitle, addressDirection, timeDetailsStackView, productDetails])
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
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Labels for Address/Button
    
    private lazy var addressDirection: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addressLabel,directionIcon])
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directionIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Direction Icon")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    @objc func directionPressed(){
        guard let unwrappedMarket = selectedMarket else {fatalError("This should never happen")}
        guard let googleMapsLink = unwrappedMarket.googleLink else {
            
            let alertVC = UIAlertController(title: "No Valid Map Link", message: "There is not a link for directions to the Farmers Market at this time", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            self.present(alertVC, animated: true)
            return
        }
        if let url = NSURL(string: googleMapsLink) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Labels for the seasonAndHour section
    
    private lazy var timeDetailsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [seasonAndHourTitle,timeDetails])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 0
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
    
    private let timeDetails : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "8:00 - 1:00"
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Labels for the Offered Products section
    
    private lazy var productDetails: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productsTitle,productsOffered])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let productsTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Products Offer"
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let productsOffered: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Baked Goods! ,ETC."
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc private func dismissToMap(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupLayout()
        directionIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(directionPressed)))
        configureDataSources()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    private func configureDataSources() {
        guard let market = selectedMarket else {fatalError("This is a very grave mistake")}
        
        let titleString = market.name
        let cleanTitleLabel = titleString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let timeString = market.time
        let cleanTimeLabel = timeString?.replace(string: "<br>", replacement: " ")
        
        marketTitle.text = cleanTitleLabel
        productsOffered.text = market.products
        addressLabel.text = market.location
        timeDetails.text = cleanTimeLabel
        
        
    }
    private func setupLayout() {
        let informationContainerView = UIView()
        informationContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(informationContainerView)
        
        informationContainerView.addSubview(marketDetailStackView)
//        informationContainerView.addSubview(timeDetails)
        informationContainerView.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            
            informationContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            informationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            informationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            informationContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            dismissButton.heightAnchor.constraint(equalTo: informationContainerView.heightAnchor, multiplier: 0.05),
            dismissButton.leadingAnchor.constraint(equalTo: marketDetailStackView.leadingAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: marketDetailStackView.topAnchor),
            
            marketDetailStackView.topAnchor.constraint(equalTo: informationContainerView.topAnchor, constant: 20),
            marketDetailStackView.leadingAnchor.constraint(equalTo: informationContainerView.leadingAnchor, constant: 20),
            marketDetailStackView.trailingAnchor.constraint(equalTo: informationContainerView.trailingAnchor, constant: -20),
            marketDetailStackView.bottomAnchor.constraint(equalTo: informationContainerView.bottomAnchor),
            
            addressDirection.topAnchor.constraint(equalTo: marketTitle.bottomAnchor),
            addressDirection.leadingAnchor.constraint(equalTo: marketDetailStackView.leadingAnchor),
            addressDirection.widthAnchor.constraint(equalTo: marketDetailStackView.widthAnchor),
            addressDirection.bottomAnchor.constraint(equalTo: timeDetails.topAnchor, constant: -110),
        
            addressLabel.trailingAnchor.constraint(equalTo: addressDirection.trailingAnchor, constant: -60),
            
            productsOffered.bottomAnchor.constraint(equalTo: marketDetailStackView.bottomAnchor, constant: 90)

            ])
    }
    
}

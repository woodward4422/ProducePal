//
//  OnBoardingViewController.swift
//  Produce Pal
//
//  Created by Ryan Nguyen on 3/2/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import UIKit
import paper_onboarding

class OnBoardingViewController: UIViewController {
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 21)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(handleDone(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleDone(_ sender: UIButton) {
        AppDelegate.shared.showMap()
    }
    
    fileprivate let items = [
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "Produce Pal Icon"),
                           title: "Welcome To Produce Pal",
                           description: "Produce Pal allows you to find local farmers markets in the area",
                           pageIcon: #imageLiteral(resourceName: "Produce Pal Icon"),
                           color: #colorLiteral(red: 0.9333333333, green: 0.9254901961, blue: 0.3058823529, alpha: 1),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "Pin"),
                           title: "Select the nearest market",
                           description: "Tapping the pin will give me additional information of the market",
                           pageIcon: #imageLiteral(resourceName: "Pin"),
                           color: #colorLiteral(red: 0.831372549, green: 0.5294117647, blue: 0.5215686275, alpha: 1),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "Map"),
                           title: "Get Directions",
                           description: "Press the directions icon to be routed to that market",
                           pageIcon: #imageLiteral(resourceName: "Map"),
                           color: #colorLiteral(red: 0.2980392157, green: 0.6784313725, blue: 0.4392156863, alpha: 1),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "Farmer"),
                           title: "Keep on Discovering",
                           description: "Explore all the Farmer’s Market around you and discover all your local produce.",
                           pageIcon: #imageLiteral(resourceName: "Farmer"),
                           color: #colorLiteral(red: 0.9803921569, green: 0.862745098, blue: 0.4666666667, alpha: 1),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        ]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        doneButton.isHidden = true
        
        setupPaperOnboardingView()
        
    }
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.11),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        // Add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        
        }
    }
}

// MARK: PaperOnboardingDelegate
extension OnBoardingViewController: PaperOnboardingDelegate {
    
    public func onboardingWillTransitonToIndex(_ index: Int) {
        doneButton.isHidden = index == 3 ? false : true
    }
    
}

// MARK: PaperOnboardingDataSource
extension OnBoardingViewController: PaperOnboardingDataSource {
    
    public func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }
    
    public func onboardingItemsCount() -> Int {
        return 4
    }

}

//MARK: Constants
extension OnBoardingViewController {
    
     static let titleFont = UIFont(name: "HelveticaNeue-Medium", size: 28.0) ?? UIFont.boldSystemFont(ofSize: 28.0)
     static let descriptionFont = UIFont(name: "HelveticaNeue-Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
}

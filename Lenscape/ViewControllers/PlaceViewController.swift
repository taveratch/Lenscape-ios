//
//  PlaceViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 23/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class PlaceViewController: UIViewController {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var numberOfPhotoLabel: UILabel!
    @IBOutlet weak var placeNameStackView: UIStackView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var recentContainerView: UIView!
    @IBOutlet weak var historyContainerView: UIView!
    
    var place: Place?
    var images: [Image] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let place = place else {
            fatalError("place cannot be nil")
        }
        
        ComponentUtil.addTapGesture(parentViewController: self, for: placeNameStackView, with: #selector(dismissView))
        
        placeNameLabel.text = place.name
        
        recentContainerView.alpha = 1
        historyContainerView.alpha = 0
    }
    
    private func fetchImageFromAPI() {
        
    }
    
    @objc private func dismissView() {
        Hero.shared.defaultAnimation = .push(direction: .right)
        dismiss(animated: true)
    }
    
    @IBAction func segmentIndexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            recentContainerView.alpha = 1
            historyContainerView.alpha = 0
        case 1:
            recentContainerView.alpha = 0
            historyContainerView.alpha = 1
        default:
            break
        }
    }
    
}

//
//  GooglePlacesAutoCompleteViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import GooglePlaces

class GooglePlacesAutoCompleteViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    var fetcher: GMSAutocompleteFetcher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetcher()
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(textField:)), for: .editingChanged)
    }
    
    private func setupFetcher() {
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        fetcher = GMSAutocompleteFetcher(bounds: nil, filter: filter)
        fetcher?.delegate = self
    }
    
    @objc func searchTextFieldDidChange(textField: UITextField) {
        fetcher!.sourceTextHasChanged(textField.text!)
    }
}

extension GooglePlacesAutoCompleteViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        for prediction in predictions {
            print(prediction.attributedPrimaryText.string)
        }
    }
    func didFailAutocompleteWithError(_ error: Error) {
        return
    }
}

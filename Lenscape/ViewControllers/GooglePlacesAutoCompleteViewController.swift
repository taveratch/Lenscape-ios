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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIImageView!
    @IBOutlet weak var searchViewWrapper: UIView!
    
    var fetcher: GMSAutocompleteFetcher?
    var searchResults: [SearchResult] = []
    var placesClient: GMSPlacesClient?
    var delegate: GooglePlacesAutoCompleteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        placesClient = GMSPlacesClient()
        
        searchViewWrapper.hero.id = "searchViewWrapper"
        setupFetcher()
        setupDismissButton()
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(textField:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    private func setupFetcher() {
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        fetcher = GMSAutocompleteFetcher(bounds: nil, filter: filter)
        fetcher?.delegate = self
    }
    
    private func setupDismissButton() {
        dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
        dismissButton.isUserInteractionEnabled = true
    }
    
    @objc private func back() {
        dismiss(animated: true)
    }
    
    @objc func searchTextFieldDidChange(textField: UITextField) {
        fetcher!.sourceTextHasChanged(textField.text!)
    }
}

extension GooglePlacesAutoCompleteViewController: GMSAutocompleteFetcherDelegate {
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        searchResults = predictions.map{ SearchResult(prediction: $0) }
        tableView.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        return
    }
}

extension GooglePlacesAutoCompleteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.SearchAutoCompleteTableViewCell.rawValue, for: indexPath) as! SearchAutoCompleteTableViewCell
        let searchResult = searchResults[indexPath.row]
        
        cell.placeNameLabel.text = searchResult.name
        cell.placeAddressLabel.text = searchResult.address
        
        return cell
    }
}

extension GooglePlacesAutoCompleteViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension GooglePlacesAutoCompleteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchResult = searchResults[indexPath.row]
        placesClient!.lookUpPlaceID(searchResult.placeID, callback: {
            place, error in
            if let place = place {
                self.delegate?.didSelectPlace(place: place)
                self.dismiss(animated: true)
            }
        })
    }
}

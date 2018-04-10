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
    private let dataProvider = GoogleDataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        placesClient = GMSPlacesClient()
        
        searchViewWrapper.hero.id = "searchViewWrapper"
        setupFetcher()
        setupDismissButton()
        fetchNearbyPlaces()
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(textField:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    private func setupFetcher() {
        var location = LocationManager.getInstance().getCurrentLocation()
        if location == nil {
            location = Location(latitude: 13.8458781, longitude: 100.5687592) //Kasetsart University
        }
        
        //set boundary to current location
        let neBoundsCorner = CLLocationCoordinate2D(latitude: location!.latitude,
                                                    longitude: location!.longitude)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: location!.latitude,
                                                    longitude: location!.longitude)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner,
                                         coordinate: swBoundsCorner)
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
        fetcher?.delegate = self
    }
    
    private func fetchNearbyPlaces() {
        let location = LocationManager.getInstance().currentLocation
        dataProvider.fetchPlacesNearCoordinate(CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude: (location?.longitude)!), radius: 1000, types: []) {
            places in
            self.searchResults = places.map { SearchResult(name: $0.name, address: $0.address, placeID: $0.placeID!) }
            self.tableView.reloadData()
//            print(places)
        }
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

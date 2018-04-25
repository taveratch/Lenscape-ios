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
    
    var place: Place?
    var searchResults: [Place] = []
    var delegate: GooglePlacesAutoCompleteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        searchViewWrapper.hero.id = "searchViewWrapper"
        setupDismissButton()
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(textField:)), for: .editingChanged)
        
        fetchPlaces(searchQuery: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    private func setupDismissButton() {
        dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
        dismissButton.isUserInteractionEnabled = true
    }
    
    @objc private func back() {
        dismiss(animated: true)
    }
    
    @objc func searchTextFieldDidChange(textField: UITextField) {
        fetchPlaces(searchQuery: textField.text!)
    }
    
    private func fetchPlaces(searchQuery: String) {
        let location = LocationManager.getInstance().getCurrentLocation()
        Api.searchLocations(currentLocation: location!, searchQuery: searchQuery).done {
            places in
            self.searchResults = places
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? "Error"
                AlertController.showAlert(viewController: self, message: message)
            }.finally {
                self.tableView.reloadData()
        }
    }
    
    /*
     unwind after click `add` from AddPlaceViewController
    */
    @IBAction func unwindToGooglePlacesAutoCompleteAndDismiss(sender: UIStoryboardSegue) {
        if place != nil {
            delegate?.didSelectPlace(place: place!)
            dismiss(animated: true)
        }
    }
}

extension GooglePlacesAutoCompleteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count + 1 // 1 is row for create new place
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < searchResults.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.SearchItemTableViewCell.rawValue, for: indexPath) as! SearchItemTableViewCell
            let searchResult = searchResults[indexPath.row]
            
            cell.placeNameLabel.text = searchResult.name
            cell.placeAddressLabel.text = searchResult.address
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.AddNewPlaceTableViewCell.rawValue, for: indexPath)
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
        if indexPath.row < searchResults.count {
            let place = searchResults[indexPath.row]
            self.delegate?.didSelectPlace(place: place)
            self.dismiss(animated: true)
        }else {
            // open add new place view controller
            let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.AddNewPlaceViewController.rawValue)
            present(vc!, animated: true)
        }
    }
}

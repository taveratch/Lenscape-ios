//
//  PlaceListViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 23/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class PlaceListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var places: [Place] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}


extension PlaceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.SearchItemTableViewCell.rawValue, for: indexPath) as! SearchItemTableViewCell
        
        cell.selectionStyle = .none
        
        let place = places[indexPath.row]
        cell.placeAddressLabel.isHidden = true
        cell.placeNameLabel.text = place.name
        
        return cell
    }
}

extension PlaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.PlaceViewController.rawValue) as! PlaceViewController
        let place = places[indexPath.row]
        vc.place = place
        Hero.shared.defaultAnimation = .push(direction: .left)
        present(vc, animated: true)
    }
}

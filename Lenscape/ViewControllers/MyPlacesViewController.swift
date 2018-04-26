//
//  MyPlacesViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 26/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class MyPlacesViewController: UIViewController {

    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    let MAX_ITEM_PER_ROW = 4
    
    // row height has to be dynamic related to height of each photo. This number includes margin and constraint
    let tableCellHeightWithoutCollectionWith: CGFloat = 62
    
    var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        setupGestures()
        fetchMyPlacesFromAPI()
    }
    
    @objc private func dismissView() {
        Hero.shared.defaultAnimation = .push(direction: .right)
        dismiss(animated: true)
    }
    
    private func setupGestures() {
        addTapGesture(for: navigationBar.backButton, with: #selector(dismissView))
    }
    
    private func fetchMyPlacesFromAPI() {
        Api.fetchMyPlaces().done {
            places in
            self.places = places
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? "Error"
                AlertController.showAlert(viewController: self, message: message)
            }.finally {
                self.tableView.reloadData()
        }
    }
}

extension MyPlacesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.MyPlaceTableViewCell.rawValue, for: indexPath) as! MyPlaceTableViewCell
        
        let place = places[indexPath.row]
        cell.placeNameLabel.text = place.name
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        return cell
    }
}

extension MyPlacesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.ImageCollectionViewCell.rawValue, for: indexPath) as! ImageCollectionViewCell
        let image = places[collectionView.tag].images[indexPath.row]
        let url = URL(string: image.thumbnailLink!)
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(with: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = places[collectionView.tag].images.count
        if count > MAX_ITEM_PER_ROW {
            return MAX_ITEM_PER_ROW
        }
        return count
    }
}

extension MyPlacesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.size.width - CGFloat(MAX_ITEM_PER_ROW+1)
        let widthPerItem = availableWidth / CGFloat(MAX_ITEM_PER_ROW)
        tableView.rowHeight = tableCellHeightWithoutCollectionWith + widthPerItem
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    // Space between column
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    // Space between row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // Remove margin of UICollectionView not cell.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

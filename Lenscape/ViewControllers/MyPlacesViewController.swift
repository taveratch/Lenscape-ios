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
                self.showAlertDialog(message: message)
            }.finally {
                self.tableView.reloadData()
        }
    }
    
    @objc private func showFullImageViewController(sender: UITapGestureRecognizerWithParam) {
        let param = sender.param as! [String: Any]
        let uiImage = param["uiImage"] as! UIImage
        let image = param["image"] as! Image
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
        vc.image = image
        vc.placeHolderImage = uiImage
        vc.imageViewHeroId = "\(image.thumbnailLink!)_MyPlace"
        Hero.shared.defaultAnimation = .fade
        present(vc, animated: true)
    }
    
    @objc private func showPhotoGridViewController(sender: UITapGestureRecognizerWithParam) {
        let param = sender.param as! [String: Any]
        let place = param["place"] as! Place
        let images = place.images
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.PhotoGridViewController.rawValue) as! PhotoGridViewController
        vc.images = images
        vc.title = place.name
        vc.place = place
        Hero.shared.defaultAnimation = .push(direction: .left)
        present(vc, animated: true)
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
        let index = indexPath.row
        let place = places[collectionView.tag]
        let image = place.images[index]
        let maxImageCount = place.numberOfPhotos
        
        // If number of image more than MAX_ITEM_PER_ROW, it shows See More CollectionViewCell
        if index == MAX_ITEM_PER_ROW - 1 && index < maxImageCount - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.MyPlaceSeeMoreCollectionViewCell.rawValue, for: indexPath) as! MyPlaceSeeMoreCollectionViewCell
            let url = URL(string: image.thumbnailLink!)
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: url)
            cell.numberLabel.text = "+\(maxImageCount-MAX_ITEM_PER_ROW)"
            
            let params: [String: Any] = [
                "place": place
            ]
            self.addTapGesture(for: cell.backgroundUIView, with: #selector(showPhotoGridViewController(sender:)), param: params)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.ImageCollectionViewCell.rawValue, for: indexPath) as! ImageCollectionViewCell
        
        let url = URL(string: image.thumbnailLink!)
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.hero.id = "\(image.thumbnailLink!)_MyPlace"
        cell.imageView.kf.setImage(with: url) {
            uiImage, _, _, _ in
            let param: [String: Any] = [
                "uiImage": uiImage,
                "image": image
            ]
            self.addTapGesture(for: cell.imageView, with: #selector(self.showFullImageViewController(sender:)), param: param)
        }
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

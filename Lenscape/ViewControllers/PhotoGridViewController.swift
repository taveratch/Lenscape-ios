//
//  PhotoGridViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 27/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class PhotoGridViewController: UIViewController {

    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [Image] = []
    var place: Place?
    
    let itemsPerRow: Int = 3
    var page = 1
    var shouldFetchMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupUI()
        fetchInitMyPhotoInThisPlaceFromAPI()
    }
    
    private func setupUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationBar.title = self.title ?? ""
    }
    
    private func setupGestures() {
        addTapGesture(for: navigationBar.backButton, with: #selector(dismissView))
    }
    
    private func fetchInitMyPhotoInThisPlaceFromAPI() {
        fetchMyPhotosInThisPlaceFromAPI(page: 1) {
            images in
            self.images = images
        }
    }
    
    private func fetchMyPhotosInThisPlaceFromAPI(page: Int = 1, modifyImageFunction: @escaping ([Image]) -> Void = { _ in }) {
        Api.getImages(placeId: self.place!.placeID, page: page, isOwner: true).done {
            response in
            let pagination = response["pagination"] as! Pagination
            let images = response["images"] as! [Image]
            self.shouldFetchMore = pagination.hasMore
            modifyImageFunction(images)
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? "Error"
                self.showAlertDialog(message: message)
            }.finally {
                self.collectionView.reloadData()
        }
    }
    
    @objc private func dismissView() {
        Hero.shared.defaultAnimation = .push(direction: .right)
        dismiss(animated: true)
    }
    
    @objc private func showFullImageViewController(sender: UITapGestureRecognizerWithParam) {
        let tapLocation = sender.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: tapLocation)
        let cell = collectionView.cellForItem(at: indexPath!) as! ImageCollectionViewCell
        let index = indexPath!.row
        let image = images[index]
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
        vc.image = image
        vc.placeHolderImage = cell.imageView.image
        vc.imageViewHeroId = "\(image.thumbnailLink!)_PhotoGrid"
        Hero.shared.defaultAnimation = .fade
        present(vc, animated: true)
    }
}

extension PhotoGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.ImageCollectionViewCell.rawValue, for: indexPath) as! ImageCollectionViewCell
        let index = indexPath.row
        
        if images.count > itemsPerRow*3, index >= images.count - (itemsPerRow*4), shouldFetchMore {
            page += 1
            fetchMyPhotosInThisPlaceFromAPI(page: page) {
                images in
                self.images += images
            }
        }
        
        let image = images[index]
        let url = URL(string: image.thumbnailLink!)
        cell.imageView.hero.id = "\(image.thumbnailLink!)_PhotoGrid"
        cell.imageView.kf.setImage(with: url)
        
        addTapGesture(for: cell.imageView, with: #selector(showFullImageViewController(sender:)) )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.size.width - CGFloat(itemsPerRow+1)
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
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

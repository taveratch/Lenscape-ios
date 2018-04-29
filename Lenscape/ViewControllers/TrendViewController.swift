//
//  TrendViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 8/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero
import Kingfisher
import ReactiveCocoa

class TrendViewController: UIViewController {

    // MARK: - Attributes
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var refreshControl = UIRefreshControl()
    @IBOutlet weak var headerView: UIStackView!
    
    var images: [Image] = []
    let itemsPerRow = 3
    var page = 1
    var shouldFetchMore = false
    var lastContentOffset: CGFloat = 0
    var shouldUpdateHeaderVisibility = true
    var countUntilShowLargeImage = 0
    var imageSizeAtIndex: [Int: (width:CGFloat, height:CGFloat)] = [:]
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        setupRefreshControl()
        fetchInitImagesFromAPI()
    }
    
    // MARK: - Private Methods
    
    @objc private func fetchInitImagesFromAPI() {
        page = 1
        fetchImagesFromAPI(page: page) {
            images in
            self.images = images
        }
    }
    
    private func isDisplayAllInOnePage() -> Bool {
        return self.images.count < 9
    }
    
    private func fetchImagesFromAPI(page: Int, modifyImageFunction: @escaping ([Image]) -> Void = { _ in }) {
        Api.fetchTrendImages(page: page).done {
            fulfill in
            
            let images = fulfill["images"] as! [Image]
            let pagination = fulfill["pagination"] as! Pagination
            modifyImageFunction(images)
            self.shouldFetchMore = pagination.hasMore && !self.isDisplayAllInOnePage()
            }.catch {
                error in
                print("error: \(error)")
            }.finally {
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func showFullPhoto(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: tapLocation)
        let cell = collectionView.cellForItem(at: indexPath!) as! ImageCollectionViewCell
        let index = indexPath!.row
        let image = images[index]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
        vc.image = image
        vc.placeHolderImage = cell.imageView.image
        
        // Observe dismiss event from modal, then notify parent (this) to do something.
        // https://github.com/ReactiveCocoa/ReactiveCocoa
        vc.reactive
            .trigger(for: #selector(vc.viewWillDisappear(_:)))
            .observe { _ in
                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
        
        Hero.shared.defaultAnimation = .fade
        present(vc, animated: true)
    }
    
    private func setupRefreshControl() {
        //Initialize Refresh Control (Pull to refresh)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(fetchInitImagesFromAPI), for: .valueChanged)
    }
    
}

// MARK: - UICollectionViewDataSource

extension TrendViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.ImageCollectionViewCell.rawValue, for: indexPath) as! ImageCollectionViewCell
        let index = indexPath.row
        // If scroll before last 4 rows then fetch the next images
        if images.count > itemsPerRow*3, index >= images.count - (itemsPerRow*4), shouldFetchMore {
            page += 1
            fetchImagesFromAPI(page: page) {
                images in
                self.images += images
            }
        }
        let image = images[index]
        let url = URL(string: image.thumbnailLink!)
        
        cell.imageView.hero.id = image.thumbnailLink!
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(with: url, options: [.transition(.fade(0.5))]) {
            uiImage, _, _, _ in
            // Show the original image from cache only
            ImageCache.default.retrieveImage(forKey: image.link!, options: nil) {
                image, _ in
                if let image = image {
                    cell.imageView.image = image
                }
            }
        }
        
        addTapGesture(for: cell.imageView, with: #selector(showFullPhoto(sender:)))
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrendViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = indexPath.row
        let availableWidth = collectionView.frame.size.width - CGFloat(itemsPerRow+1)
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        let sizeFromCache = imageSizeAtIndex[index]
        if let sizeFromCache = sizeFromCache {
            return CGSize(width: sizeFromCache.width, height: sizeFromCache.height)
        }
        
        switch index {
        case 0:
            let widthPerItem = availableWidth / CGFloat(3)
            let width = collectionView.frame.size.width
            let height = widthPerItem * 2
            return CGSize(width: width, height: height)
        case 1,2:
            let numberOfItemInRow = 2
            let availableWidth = collectionView.frame.size.width - CGFloat(numberOfItemInRow+1)
            let widthPerItem = availableWidth / CGFloat(numberOfItemInRow)
            return CGSize(width: widthPerItem, height: widthPerItem)
        default:
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
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

extension TrendViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if lastContentOffset - yOffset > 100, shouldUpdateHeaderVisibility {
            // going up
            headerView.hideWithAnimation(isHidden: false, duration: 0.1)
            shouldUpdateHeaderVisibility = false
        } else if lastContentOffset - yOffset < -100, shouldUpdateHeaderVisibility {
            // going down
            headerView.hideWithAnimation(isHidden: true, duration: 0.1)
            shouldUpdateHeaderVisibility = false
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        shouldUpdateHeaderVisibility = true
    }
}


//
//  ExploreViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 6/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftCarousel
import Hero

class ExploreViewController: AuthViewController {
    
    //MARK: - UI Components
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressViewWrapper: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var seasoningScrollView: CircularInfiniteScroll!
    private lazy var refreshControl = UIRefreshControl()
    
    var items = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var itemsViews: [CircularScrollViewItem]?
    let colors = [#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1),#colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6588235294, alpha: 1),#colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.4352941176, alpha: 1),#colorLiteral(red: 0.8980392157, green: 0.5803921569, blue: 0.2156862745, alpha: 1),#colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.6196078431, blue: 0.1882352941, alpha: 1),#colorLiteral(red: 1, green: 0.7215686275, blue: 0.4117647059, alpha: 1),#colorLiteral(red: 1, green: 0.8431372549, blue: 0.6823529412, alpha: 1),#colorLiteral(red: 0.8823529412, green: 0.8352941176, blue: 0.7450980392, alpha: 1),#colorLiteral(red: 0.7725490196, green: 0.8274509804, blue: 0.8078431373, alpha: 1),#colorLiteral(red: 0.6588235294, green: 0.8196078431, blue: 0.8705882353, alpha: 1),#colorLiteral(red: 0.5490196078, green: 0.8117647059, blue: 0.9333333333, alpha: 1),#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1)]
    let photoUploader = PhotoUploader()
    var images: [Image] = []
    let itemsPerRow: Int = 3
    var numberOfPhotos = 0 {
        didSet {
            self.descriptionLabel.text = "\(self.numberOfPhotos) Photos"
        }
    }
    var page = 1
    var shouldFetchMore = false
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoUploader.delegate = self
        collectionView.delegate = self
        setupUI()
        
        //Make ExploreViewController as observer for LocationManager (this vc will be notify from MainTabBarController (CLLocationManagerDelegate))
        NotificationCenter.default.addObserver(self, selector: #selector(fetchInitImageFromAPI), name: .DidUpdateLocation, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUploadPhoto()
    }
    
    // MARK: - Private Methods
    
    private func startUploadPhoto() {
        if let uploadPhoto = UserDefaults.standard.data(forKey: "uploadPhotoData") {
            let locationManager = LocationManager.getInstance()
            photoUploader.upload(data: uploadPhoto, location: locationManager.getCurrentLocation())
            UserDefaults.standard.removeObject(forKey: "uploadPhotoData")
        }
    }
    
    @objc private func fetchInitImageFromAPI() {
        page = 1
        fetchImagesFromAPI(page: page) {
            images in
            self.images = images
        }
    }
    
    private func isDisplayAllInOnePage() -> Bool {
        return self.images.count < 9
    }
    
    private func fetchImagesFromAPI(page: Int = 1, modifyImageFunction: @escaping ([Image]) -> Void = { _ in }) {
        Api.fetchExploreImages(page: page, location: LocationManager.getInstance().getCurrentLocation()!).done {
            fulfill in
            
            let images = fulfill["images"] as! [Image]
            let pagination = fulfill["pagination"] as! Pagination
            modifyImageFunction(images)
            self.numberOfPhotos = pagination.totalNumberOfEntities
            self.shouldFetchMore = pagination.hasMore && !self.isDisplayAllInOnePage()
            }.catch {
                error in
                print("error: \(error)")
            }.finally {
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
        }
    }
    
    private func setupUI() {
        // MARK: Seasoning Scroll View
        do {
            try seasoningScrollView.carousel.itemsFactory(itemsCount: 12, factory: labelForMonthItem)
        } catch  {
            
        }
        seasoningScrollView.carousel.delegate = self
        seasoningScrollView.carousel.resizeType = .visibleItemsPerPage(9)
        seasoningScrollView.carousel.defaultSelectedIndex = 6
        
        // Initialize Refresh Control (Pull to refresh)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(fetchInitImageFromAPI), for: .valueChanged)
    }
    
    @objc private func showMapView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.ExploreMapViewController.rawValue)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc private func showPhotoInfoVC(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: tapLocation)
        let cell = collectionView.cellForItem(at: indexPath!) as! ImageCollectionViewCell
        let index = indexPath!.row
        let image = images[index]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.PhotoInfoViewController.rawValue) as! PhotoInfoViewController
        vc.image = image
        vc.uiImage = cell.imageView.image
        vc.hero.modalAnimationType = .fade
        present(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func labelForMonthItem(index: Int) -> CircularScrollViewItem {
        let string = items[index]
        let viewContainer = CircularScrollViewItem()
        viewContainer.label.text = string
        viewContainer.label.font = .systemFont(ofSize: 14.0)
        viewContainer.contentView.startColor = colors[index]
        viewContainer.contentView.endColor = colors[index+1]
        viewContainer.contentView.sizeToFit()
        return viewContainer
    }
    
    // MARK: - unwind
    @IBAction func unwindToGridView(sender: UIStoryboardSegue) {
        
    }
    
}

// MARK: - PhotoUploadingDelegate

extension ExploreViewController: PhotoUploadingDelegate {
    
    func didUpload() {
        self.progressViewWrapper.isHidden = true
        UserDefaults.standard.removeObject(forKey: "uploadPhotoData")
        UIView.animate(withDuration: 0.5, animations: {
            self.fetchInitImageFromAPI()
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
        print("didUpload")
    }
    
    func uploading(completedUnit: Double, totalUnit: Double) {
        self.progressViewWrapper.isHidden = false
        UIView.animate(withDuration: 3, delay: 0.0, options: .curveLinear, animations: {
            self.progressView.setProgress(Float(completedUnit/totalUnit), animated: true)
        }, completion: nil)
        print("uploading \(completedUnit)/\(totalUnit)")
    }
    
    func willUpload() {
        self.progressViewWrapper.isHidden = false
        self.progressView.progress = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
        print("willUpload")
    }
}

// MARK: - SwiftCarouselDelegate

extension ExploreViewController: SwiftCarouselDelegate {
    
    func didSelectItem(item: UIView, index: Int, tapped: Bool) -> UIView? {
        return item
    }
    
    func didDeselectItem(item: UIView, index: Int) -> UIView? {
        return item
    }
}

// MARK: - UICollectionViewDataSource

extension ExploreViewController: UICollectionViewDataSource {
    
    //Number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    //Initialize cell's ui
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.ImageColelctionViewCell.rawValue, for: indexPath) as! ImageCollectionViewCell
        let index = indexPath.row
        // If scroll before last 3 rows then fetch the next images
        if images.count > itemsPerRow*4, index >= images.count - (itemsPerRow*4), shouldFetchMore {
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
        cell.imageView.kf.setImage(with: url, options: [.transition(.fade(0.5))])
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPhotoInfoVC(sender:)))
        cell.imageView.addGestureRecognizer(tap)
        cell.imageView.isUserInteractionEnabled = true
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // CollectionView's supplementary (used as header)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identifier.ExploreSupplementaryCollectionReusableView.rawValue, for: indexPath) as! ExploreSupplementaryView
            
            if let user = UserController.getCurrentUser() {
                let profileImage = user["picture"] as! String
                let url = URL(string: profileImage)
                headerView.tabHeader.profileImage.kf.setImage(with: url, options: [.transition(.fade(0.5))])
            }
            headerView.tabHeader.titleLabel.text = "Around you"
            self.descriptionLabel = headerView.tabHeader.descriptionLabel
            
            if self.progressView != nil {
                headerView.progressView.progress = self.progressView.progress
                headerView.progressBarWrapper.isHidden = self.progressViewWrapper.isHidden
            }
            self.progressView = headerView.progressView
            self.progressViewWrapper = headerView.progressBarWrapper
            //            let tap = UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.showMapView))
            //            headerView.switchViewToMap.addGestureRecognizer(tap)
            //            headerView.switchViewToMap.isUserInteractionEnabled = true
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ExploreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.size.width - CGFloat(itemsPerRow+1)
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //Space between column
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.progressViewWrapper != nil, !self.progressViewWrapper.isHidden {
            return CGSize(width: collectionView.bounds.size.width, height: 135)
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 135 - 40)
        }
    }
}


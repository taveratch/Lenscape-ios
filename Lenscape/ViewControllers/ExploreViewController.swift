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

class ExploreViewController: AuthViewController, PhotoUploadingDelegate {

    //MARK: - UI Components
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var seasoningScrollView: CircularInfiniteScroll!
    
    var items = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var itemsViews: [CircularScrollViewItem]?
    let colors = [#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1),#colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6588235294, alpha: 1),#colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.4352941176, alpha: 1),#colorLiteral(red: 0.8980392157, green: 0.5803921569, blue: 0.2156862745, alpha: 1),#colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.6196078431, blue: 0.1882352941, alpha: 1),#colorLiteral(red: 1, green: 0.7215686275, blue: 0.4117647059, alpha: 1),#colorLiteral(red: 1, green: 0.8431372549, blue: 0.6823529412, alpha: 1),#colorLiteral(red: 0.8823529412, green: 0.8352941176, blue: 0.7450980392, alpha: 1),#colorLiteral(red: 0.7725490196, green: 0.8274509804, blue: 0.8078431373, alpha: 1),#colorLiteral(red: 0.6588235294, green: 0.8196078431, blue: 0.8705882353, alpha: 1),#colorLiteral(red: 0.5490196078, green: 0.8117647059, blue: 0.9333333333, alpha: 1),#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1)]
    let photoUploader = PhotoUploader()
    var images: [Image] = []
    fileprivate let itemsPerRow: CGFloat = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoUploader.delegate = self
        collectionView.delegate = self
        setupUI()
        initImagesFromAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUploadPhoto()
    }
    
    private func startUploadPhoto() {
        if let uploadPhoto = UserDefaults.standard.data(forKey: "uploadPhotoData") {
            photoUploader.upload(data: uploadPhoto)
            UserDefaults.standard.removeObject(forKey: "uploadPhotoData")
        }
    }
    
    private func initImagesFromAPI() {
        Api.fetchExploreImages().done {
            images in
            self.images = images
            self.collectionView.reloadData()
            }.catch {
                error in
                print("error: \(error)")
        }
    }
    
    private func setupUI() {
        // MARK: - Seasoning Scroll View
        do {
            try seasoningScrollView.carousel.itemsFactory(itemsCount: 12, factory: labelForMonthItem)
        } catch  {
            
        }
        seasoningScrollView.carousel.delegate = self
        seasoningScrollView.carousel.resizeType = .visibleItemsPerPage(9)
        seasoningScrollView.carousel.defaultSelectedIndex = 6
    }
    
    @objc private func showMapView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.ExploreMapViewController.rawValue)
        self.navigationController?.pushViewController(vc!, animated: true)
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
    
    // MARK: - PhotoUploaderDelegate functions
    func didUpload() {
        self.progressView.isHidden = true
        UserDefaults.standard.removeObject(forKey: "uploadPhotoData")
        initImagesFromAPI()
        print("didUpload")
    }
    
    func uploading(completedUnit: Double, totalUnit: Double) {
        self.progressView.isHidden = false
        UIView.animate(withDuration: 3, delay: 0.0, options: .curveLinear, animations: {
            self.progressView.setProgress(Float(completedUnit/totalUnit), animated: true)
        }, completion: nil)
        print("uploading \(completedUnit)/\(totalUnit)")
    }
    
    func willUpload() {
        self.progressView.isHidden = false
        self.progressView.progress = 0
        print("willUpload")
    }
}

// MARK: - SwiftCarouselDelegate functions
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.ImageColelctionViewCell.rawValue, for: indexPath) as! ImageCollectionViewCell
        let index = indexPath.row
        let image = images[index]
        let url = URL(string: image.thumbnailLink!)
        cell.imageView.kf.setImage(with: url)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identifier.ExploreSupplementaryCollectionReusableView.rawValue, for: indexPath) as! ExploreSupplementaryView
            headerView.tabHeader.titleLabel.text = "Around you"
            headerView.tabHeader.descriptionLabel.text = "150+ Photos"
            let user = UserController.getCurrentUser()!
            if let profileImageUrl = user["picture"] as? String {
                let url = URL(string: profileImageUrl)
                headerView.tabHeader.profileImage.kf.setImage(with: url)
            }
            if self.progressView != nil {
                headerView.progressView.progress = self.progressView.progress
                headerView.progressView.isHidden = self.progressView.isHidden
            }
            self.progressView = headerView.progressView
            let tap = UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.showMapView))
            headerView.switchViewToMap.addGestureRecognizer(tap)
            headerView.switchViewToMap.isUserInteractionEnabled = true
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

extension ExploreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.size.width - (itemsPerRow+1)
        let widthPerItem = availableWidth / (itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}


//
//  ProfileViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 8/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var refreshControl = UIRefreshControl()
    
    var images: [Image] = []
    let itemsPerRow = 3
    var page = 0
    var shouldFetchMore = true
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        initImagesFromAPI()
    }
    
    // MARK: - Private Methods
    
    @objc private func initImagesFromAPI() {
        shouldFetchMore = true
        page = 0
        Api.fetchUserImages().done {
            images in
            self.images = images
            }.catch {
                error in
                print("error: \(error)")
            }.finally {
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
        }
    }
    
    private func fetchMoreImagesFromAPI(page: Int) {
        shouldFetchMore = false
        Api.fetchUserImages(page: page).done {
            images in
            if images.count != 0 {
                self.images += images
                self.collectionView.reloadData()
                self.shouldFetchMore = true
            }
            }.catch {
                error in
                print("error: \(error)")
        }
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
    
    private func setupRefreshControl() {
        //Initialize Refresh Control (Pull to refresh)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(initImagesFromAPI), for: .valueChanged)
    }
    
    @objc private func showSettingsVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.SettingsNavigationController.rawValue)
        present(vc!, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.ImageColelctionViewCell.rawValue, for: indexPath) as! ImageCollectionViewCell
        let index = indexPath.row
        
        // If scroll before last 4 rows then fetch the next images
        if images.count > itemsPerRow*3, index >= images.count - (itemsPerRow*4), shouldFetchMore {
            page += 1
            fetchMoreImagesFromAPI(page: page)
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
    
    // CollectionView's supplementary (used as header)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileCollectionReusableView", for: indexPath)
            guard let profileHeader = headerView.subviews[0] as? ProfileInfoView else {
                fatalError("No header exists")
            }
            
            if let user = UserController.getCurrentUser() {
                let profileImage = user["picture"] as! String
                let url = URL(string: profileImage)
                profileHeader.profileImage.kf.setImage(with: url, options: [.transition(.fade(0.5))])
                profileHeader.nameLabel.text = "\(user["firstname"] ?? "") \(user["lastname"] ?? "")"
                profileHeader.descriptionLabel.text = user["email"] as? String
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(showSettingsVC))
            profileHeader.settingsButton.addGestureRecognizer(tap)
            profileHeader.settingsButton.isUserInteractionEnabled = true

            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
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

// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate

extension ProfileViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Images"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "When you have images, you'll see them here."
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
//    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
//        return UIImage(named: "Red heart")
//    }
    
//    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
//        let str = "Add an image"
//        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)]
//        return NSAttributedString(string: str, attributes: attrs)
//    }
    
//    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
//        let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "Hurray", style: .default))
//        present(ac, animated: true)
//    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        // Using ProfileInfoView header with height 300
        return 150
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor(cgColor: #colorLiteral(red: 0.9401558042, green: 0.952983439, blue: 0.956292212, alpha: 1))
    }
    
}



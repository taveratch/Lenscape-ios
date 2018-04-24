//
//  PlaceViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 23/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero
import Kingfisher
import ReactiveCocoa

class PlaceViewController: UIViewController {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var numberOfPhotoLabel: UILabel!
    @IBOutlet weak var placeNameStackView: UIStackView!
    @IBOutlet weak var hofPhotoNameLabel: UILabel!
    @IBOutlet weak var hofOwnerNameLabel: UILabel!
    @IBOutlet weak var hofOwnerProfileImage: EnhancedUIImage!
    @IBOutlet weak var hofImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hofWrapper: UIView!
    @IBOutlet weak var statusbarSpaceView: UIView!
    
    var place: Place?
    var hof: Image?
    var images: [Image] = []
    var placeRecentPhotoViewController: PlaceRecentPhotoViewController?
    var page = 1
    var shouldFetchMore = false
    
    var lastContentOffset: CGFloat = 0
    var shouldUpdateHeaderVisibility = true
    
    // Fix tableview row's offset change after call reloadRowsAt... in likeImage()
    // https://stackoverflow.com/questions/27102887/maintain-offset-when-reloadrowsatindexpaths
    fileprivate var heightForIndexPath = [IndexPath: CGFloat]()
    fileprivate let averageRowHeight: CGFloat = 312 //your best estimate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupUI()
    }
    
    private func setupUI() {
        statusbarSpaceView.isHidden = true
        
        guard let place = place else {
            fatalError("place cannot be nil")
        }
        fetchInitImagesFromAPI()
        
        ComponentUtil.addTapGesture(parentViewController: self, for: placeNameStackView, with: #selector(dismissView))
        
        placeNameLabel.text = place.name
    }
    
    private func showFullImageViewController(image: Image, uiImage: UIImage) -> UIViewController{
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
        vc.image = image
        vc.placeHolderImage = uiImage
        
        Hero.shared.defaultAnimation = .fade
        return vc
    }
    
    @objc private func showFullImageGestureHandler(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: tapLocation)
        let cell = tableView.cellForRow(at: indexPath!) as! PlaceVCFeedItemTableViewCell
        let feedItem: FeedItem = cell.feedItem
        let index = indexPath!.row
        let image = images[index]
        
        let vc = showFullImageViewController(image: image, uiImage: feedItem.imageView.image!)
        
        // Observe dismiss event from modal, then notify parent (this) to do something.
        // https://github.com/ReactiveCocoa/ReactiveCocoa
        vc.reactive
            .trigger(for: #selector(vc.viewWillDisappear(_:)))
            .observe { _ in
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
        present(vc, animated: true)
    }
    
    private func getHOFImage(images: [Image]) -> Image? {
        let sortedImages: [Image] = images.sorted(by: {$0.likes! > $1.likes!} )
        return sortedImages.first
    }
    
    @objc private func showFullHOFImage() {
        let vc = showFullImageViewController(image: hof!, uiImage: hofImage.image!) as! FullImageViewController
        vc.imageViewHeroId = "\(hof!.thumbnailLink!)_HOF"
        present(vc, animated: true)
    }
    
    private func setupHOFUI(image: Image) {
        hofImage.hero.id = "\(image.thumbnailLink!)_HOF"
        ComponentUtil.addTapGesture(parentViewController: self, for: hofImage, with: #selector(showFullHOFImage))
        
        let imageUrl = URL(string: image.thumbnailLink!)
        
        hofImage.kf.indicatorType = .activity
        
        // Load thumbnail first, then load original resolution later.
        hofImage.kf.setImage(with: imageUrl, options: [.forceTransition]) {
            img, error, cacheType, url in
            let imageUrl = URL(string: image.link!)
            self.hofImage.kf.setImage(with: imageUrl, placeholder: img)
        }
        
        let profileImageUrl = URL(string: image.owner.profilePictureLink)
        hofOwnerProfileImage.kf.setImage(with: profileImageUrl)
        
        hofOwnerNameLabel.text = image.owner.name
        hofPhotoNameLabel.text = image.name
    }
    
    private func showHOF(isShow: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.hofWrapper.isHidden = !isShow
            self.statusbarSpaceView.isHidden = isShow
            self.numberOfPhotoLabel.isHidden = !isShow
        })
    }
    
    private func fetchInitImagesFromAPI() {
        fetchImagesFromAPI(page: 1) {
            images in
            self.images = images
            if let hofImage = self.getHOFImage(images: images) {
                self.hof = hofImage
                self.setupHOFUI(image: hofImage)
            }
        }
    }
    
    private func fetchImagesFromAPI(page: Int = 1, modifyImagesFunction: @escaping ([Image]) -> Void = { _ in }) {
        let _ = Api.getImages(placeId: place!.placeID, page: page).done {
            response in
            let pagination = response["pagination"] as! Pagination
            let images = response["images"] as! [Image]
            modifyImagesFunction(images)
            self.numberOfPhotoLabel.text = "\(String(pagination.totalNumberOfEntities)) Photos"
            self.shouldFetchMore = pagination.hasMore
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? ""
                AlertController.showAlert(viewController: self, message: "Error. \(message)")
                self.dismissView()
            }.finally {
                self.tableView.reloadData()
        }
    }
    
    @objc private func likeImage(sender: UIButton) {
        let index = sender.tag
        
        guard index >= 0 && index < images.count else {
            fatalError("sender.tag must be number in range of 0..images.count")
        }
        
        let image = images[index]
        let updateImage = {
            image.is_liked = !image.is_liked
            image.likes! += image.is_liked ? 1 : -1
            sender.setImage(UIImage(named: image.is_liked ? "Red heart": "Gray Heart"), for: .normal)
        }
        updateImage()
        
        // Reload table row immediately with updated image's info
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        
        let _ = Api.likeImage(imageId: image.id, liked: image.is_liked).done {
            image in
            self.images[index] = image
            }.catch {
                error in
                //Update back to state before press
                updateImage()
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as! String
                AlertController.showAlert(viewController: self, title: "Error", message: "Status code: \(nsError.code). \(message)")
            }.finally {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    @objc private func dismissView() {
        Hero.shared.defaultAnimation = .push(direction: .right)
        print("dismiss")
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is PlaceRecentPhotoViewController:
            let vc = segue.destination as! PlaceRecentPhotoViewController
            placeRecentPhotoViewController = vc
        default:
            break
        }
    }
}

extension PlaceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.PlaceVCFeedItemTableViewCell.rawValue, for: indexPath) as! PlaceVCFeedItemTableViewCell
        let feedItem: FeedItem = cell.feedItem
        let image = images[indexPath.row]
        let profileImageUrl = URL(string: image.owner.profilePictureLink)
        feedItem.ownerProfileImageView.kf.setImage(with: profileImageUrl, options: [.transition(.fade(0.5))])
        
        feedItem.ownerNameLabel.text = image.owner.name
        
        let imageUrl = URL(string: image.thumbnailLink!)
        feedItem.imageView.kf.indicatorType = .activity
        feedItem.imageView.kf.setImage(with: imageUrl, options: [.transition(.fade(0.5))], completionHandler: {
            (downloadedImage, error, cacheType, imageUrl) in
            // Show the original image from cache only
            ImageCache.default.retrieveImage(forKey: image.link!, options: nil) {
                (image, cacheType) in
                if let image = image {
                    feedItem.imageView.image = image
                }
            }
        })
        
        // Used for animation between this and PhotoInfoViewController
        feedItem.imageView.hero.id = image.thumbnailLink!
        
        feedItem.numberOfLikeLabel.text = "\(image.likes!)"
        
        ComponentUtil.addTapGesture(parentViewController: self, for: feedItem.imageView, with: #selector(showFullImageGestureHandler(sender:)))
        
        // Tag like button with row number. use "tag" to get specific image in like()
        feedItem.likeButton.tag = indexPath.row
        feedItem.likeButton.setImage(UIImage(named: image.is_liked ? "Red heart": "Gray Heart"), for: .normal)
        
        feedItem.likeButton.addTarget(self, action: #selector(likeImage(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
}

extension PlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        heightForIndexPath[indexPath] = cell.frame.height
        
        let lastElement = images.count - 1
        if indexPath.row == lastElement, shouldFetchMore {
            page += 1
            fetchImagesFromAPI(page: page) {
                images in
                self.images += images
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForIndexPath[indexPath] ?? averageRowHeight
    }
}

extension PlaceViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // If there is one image, do not hide HOF cause this image is perfectly shown in UI
        if self.images.count <= 1 {
            return
        }
        let yOffset = scrollView.contentOffset.y
        if yOffset == 0, shouldUpdateHeaderVisibility {
            // going up
            showHOF(isShow: true)
            shouldUpdateHeaderVisibility = false
        }else if lastContentOffset - yOffset < -50, shouldUpdateHeaderVisibility {
            // going down
            showHOF(isShow: false)
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

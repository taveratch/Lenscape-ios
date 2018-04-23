//
//  PlaceViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 23/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class PlaceViewController: UIViewController {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var numberOfPhotoLabel: UILabel!
    @IBOutlet weak var placeNameStackView: UIStackView!
    
    var place: Place?
    var images: [Image] = []
    var placeRecentPhotoViewController: PlaceRecentPhotoViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let place = place else {
            fatalError("place cannot be nil")
        }
        fetchInitImageFromAPI()
        
        ComponentUtil.addTapGesture(parentViewController: self, for: placeNameStackView, with: #selector(dismissView))
        
        placeNameLabel.text = place.name
       
    }
    
    private func fetchInitImageFromAPI() {
        fetchImageFromAPI(page: 1) {
            images in
            self.images = images
        }
    }
    
    private func fetchImageFromAPI(page: Int = 1, modifyImagesFunction: @escaping ([Image]) -> Void = { _ in }) {
        let _ = Api.getImages(placeId: place!.placeID, page: page).done {
            response in
            let pagination = response["pagination"] as! Pagination
            let images = response["images"] as! [Image]
            modifyImagesFunction(images)
            self.numberOfPhotoLabel.text = "\(String(pagination.totalNumberOfEntities)) Photos"
            }.catch {
                error in
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as? String ?? ""
                AlertController.showAlert(viewController: self, message: "Error. \(message)")
                self.dismissView()
        }
    }
    
    @objc private func dismissView() {
        Hero.shared.defaultAnimation = .push(direction: .right)
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

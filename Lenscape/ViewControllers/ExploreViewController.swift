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

class ExploreViewController: AuthViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var seasoningScrollView: CircularInfiniteScroll!
    @IBOutlet weak var mapViewImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var items = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var itemsViews: [CircularScrollViewItem]?
    let colors = [#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1),#colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6588235294, alpha: 1),#colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.4352941176, alpha: 1),#colorLiteral(red: 0.8980392157, green: 0.5803921569, blue: 0.2156862745, alpha: 1),#colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.6196078431, blue: 0.1882352941, alpha: 1),#colorLiteral(red: 1, green: 0.7215686275, blue: 0.4117647059, alpha: 1),#colorLiteral(red: 1, green: 0.8431372549, blue: 0.6823529412, alpha: 1),#colorLiteral(red: 0.8823529412, green: 0.8352941176, blue: 0.7450980392, alpha: 1),#colorLiteral(red: 0.7725490196, green: 0.8274509804, blue: 0.8078431373, alpha: 1),#colorLiteral(red: 0.6588235294, green: 0.8196078431, blue: 0.8705882353, alpha: 1),#colorLiteral(red: 0.5490196078, green: 0.8117647059, blue: 0.9333333333, alpha: 1),#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProgressView()
    }
    
    private func setupUI() {
        //MARK: - User profile image
        let user = UserController.getCurrentUser()!
        if let profileImageUrl = user["picture"] as? String {
            let url = URL(string: profileImageUrl)
            profileImage.kf.setImage(with: url)
        }
        
        // MARK: - UIImageView go to Map View
        let tap = UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.showMapView))
        mapViewImage.addGestureRecognizer(tap)
        mapViewImage.isUserInteractionEnabled = true
        
        // MARK: - Seasoning Scroll View
        do {
            try seasoningScrollView.carousel.itemsFactory(itemsCount: 12, factory: labelForMonthItem)
        } catch  {
            
        }
        seasoningScrollView.carousel.delegate = self
        seasoningScrollView.carousel.resizeType = .visibleItemsPerPage(9)
        seasoningScrollView.carousel.defaultSelectedIndex = 6
    }
    
    func setupProgressView() {
        self.progressView.setProgress(0, animated: false)
        let observer = { () -> Void in
            UIView.animate(withDuration: 3, delay: 0.0, options: .curveLinear, animations: {
                self.progressView.isHidden = false
                self.progressView.setProgress(Float(UploadController.percentage/100.0), animated: true)
                if !UploadController.isUploading {
                    self.progressView.isHidden = true
                    self.progressView.progress = 0
                }
            }, completion: nil)
        }
        UploadController.addObserver(closure: observer)
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
}

extension ExploreViewController: SwiftCarouselDelegate {
    
    func didSelectItem(item: UIView, index: Int, tapped: Bool) -> UIView? {
        return item
    }
    
    func didDeselectItem(item: UIView, index: Int) -> UIView? {
        return item
    }
}


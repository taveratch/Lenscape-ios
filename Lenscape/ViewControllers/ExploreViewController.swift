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
    
    @IBOutlet weak var selectedItemLabel: UILabel!
    @IBOutlet weak var carousel: SwiftCarousel!
    @IBOutlet weak var mapViewImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    var items: [String]?
    var itemsViews: [UILabel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        items = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        itemsViews = items!.map { labelForString($0) }
        carousel.items = itemsViews!
        carousel.resizeType = .visibleItemsPerPage(12)
        carousel.defaultSelectedIndex = 1
        carousel.delegate = self
        carousel.scrollType = .default
    }
    
    private func setupUI() {
        let user = UserController.getCurrentUser()!
        if let profileImageUrl = user["profilePicture"] as? String {
            let url = URL(string: profileImageUrl)
            profileImage.kf.setImage(with: url)
        }
        
        // Map view : UIImageView
        let tap = UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.showMapView))
        mapViewImage.addGestureRecognizer(tap)
        mapViewImage.isUserInteractionEnabled = true
    }
    
    @objc private func showMapView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.ExploreMapViewController.rawValue)
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    @IBAction func selectTiger(_ sender: UIButton) {
        carousel.selectItem(1, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func labelForString(_ string: String) -> UILabel {
        let text = UILabel()
        text.text = string
        text.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        text.textAlignment = .center
        text.font = .systemFont(ofSize: 14.0)
        text.numberOfLines = 0
        return text
    }
    
    @IBAction func unwindToGridView(sender: UIStoryboardSegue) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ExploreViewController: SwiftCarouselDelegate {
    func didSelectItem(item: UIView, index: Int, tapped: Bool) -> UIView? {
        if let animal = item as? UILabel {
            animal.textColor = UIColor.red
            selectedItemLabel.text = "Show photos in \(animal.text!)"
            return animal
        }
        
        return item
    }
    
    func didDeselectItem(item: UIView, index: Int) -> UIView? {
        if let animal = item as? UILabel {
            animal.textColor = .black
            
            return animal
        }
        
        return item
    }
    
    func didScroll(toOffset offset: CGPoint) {
        selectedItemLabel.text = "Spinning up!"
    }
    
    func willBeginDragging(withOffset offset: CGPoint) {
        selectedItemLabel.text = "So you're gonna drag me now?"
    }
    
    func didEndDragging(withOffset offset: CGPoint) {
        selectedItemLabel.text = "Oh, here we go!"
    }
}

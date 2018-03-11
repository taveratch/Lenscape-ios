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
    
    
    @IBOutlet weak var someView: UIView!
    //    @IBOutlet weak var selectedItemLabel: UILabel!
    @IBOutlet weak var carousel: SwiftCarousel!
    @IBOutlet weak var mapViewImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var items: [String]?
    var itemsViews: [UIView]?
    let colors = [#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1),#colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6588235294, alpha: 1),#colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.4352941176, alpha: 1),#colorLiteral(red: 0.8980392157, green: 0.5803921569, blue: 0.2156862745, alpha: 1),#colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.6196078431, blue: 0.1882352941, alpha: 1),#colorLiteral(red: 1, green: 0.7215686275, blue: 0.4117647059, alpha: 1),#colorLiteral(red: 1, green: 0.8431372549, blue: 0.6823529412, alpha: 1),#colorLiteral(red: 0.8823529412, green: 0.8352941176, blue: 0.7450980392, alpha: 1),#colorLiteral(red: 0.7725490196, green: 0.8274509804, blue: 0.8078431373, alpha: 1),#colorLiteral(red: 0.6588235294, green: 0.8196078431, blue: 0.8705882353, alpha: 1),#colorLiteral(red: 0.5490196078, green: 0.8117647059, blue: 0.9333333333, alpha: 1),#colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        items = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        itemsViews = items!.enumerated().map { labelForString(text: $1, index: $0) }
        carousel.items = itemsViews!
        carousel.resizeType = .visibleItemsPerPage(10)
        carousel.defaultSelectedIndex = 1
        carousel.delegate = self
        carousel.scrollType = .default
    }
    
    private func gradientCarousel() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = carousel.bounds
        let color1 = #colorLiteral(red: 0.5725490196, green: 0.7333333333, blue: 0.8823529412, alpha: 1)
        let color2 = #colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1)
        let color3 = #colorLiteral(red: 1, green: 0.8431372549, blue: 0.6823529412, alpha: 1)
        let color4 = #colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1)
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0, 0.25, 0.75, 1]
        carousel.layer.addSublayer(gradientLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gradientView()
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
    
    private func gradientView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let color1 = #colorLiteral(red: 0.5725490196, green: 0.7333333333, blue: 0.8823529412, alpha: 1)
        let color2 = #colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1)
        let color3 = #colorLiteral(red: 1, green: 0.8431372549, blue: 0.6823529412, alpha: 1)
        let color4 = #colorLiteral(red: 0.4274509804, green: 0.8039215686, blue: 1, alpha: 1)
        gradientLayer.colors = [color1, color2, color3, color4]
        //        gradientLayer.locations = [0, 0.25, 0.75, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.view.layer.addSublayer(gradientLayer)
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
    
    func labelForString(text string: String,index index: Int) -> UIView {
        print(index)
        let viewContainer = GradientView()
        let text = UILabel()
        text.text = string
        text.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        text.baselineAdjustment = .alignCenters
        text.textAlignment = .center
        text.font = .systemFont(ofSize: 14.0)
        text.sizeToFit()
        text.numberOfLines = 0
        viewContainer.startColor = colors[index]
        viewContainer.endColor = colors[index+1]
        viewContainer.shadowColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        viewContainer.sizeToFit()
        viewContainer.endPointX = 1
        viewContainer.shadowBlur = 0
        viewContainer.addSubview(text)
        return viewContainer
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
//        if let animal = item as? UILabel {
//            animal.textColor = UIColor.red
////            selectedItemLabel.text = "Show photos in \(animal.text!)"
//            return animal
//        }
        
        return item
    }
    
    func didDeselectItem(item: UIView, index: Int) -> UIView? {
//        if let animal = item as? UILabel {
//            animal.textColor = .black
//
//            return animal
//        }
        
        return item
    }
    
    func didScroll(toOffset offset: CGPoint) {
//        selectedItemLabel.text = "Spinning up!"
    }
    
    func willBeginDragging(withOffset offset: CGPoint) {
//        selectedItemLabel.text = "So you're gonna drag me now?"
    }
    
    func didEndDragging(withOffset offset: CGPoint) {
//        selectedItemLabel.text = "Oh, here we go!"
    }
}

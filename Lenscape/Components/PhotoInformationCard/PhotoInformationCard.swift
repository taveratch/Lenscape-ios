//
//  PhotoInformationCard.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 23/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import GoogleMaps

@IBDesignable
class PhotoInformationCard: UIView {

    @IBOutlet var hiddenView: [UIView]!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var moreDetailButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var pictureNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "PhotoInformationCard", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    private func commonInit() {
        let view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func isHideInfo(hide: Bool) {
        for view in hiddenView {
            view.isHidden = hide
        }
    }

}

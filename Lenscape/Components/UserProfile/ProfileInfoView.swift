//
//  ProfileInfoView.swift
//  Lenscape
//
//  Created by Thongrapee Panyapatiphan on 3/22/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable
class ProfileInfoView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: EnhancedUIImage!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var settingsButton: UIView!
    @IBOutlet weak var numberOfUploadedPhotoLabel: UILabel!
    @IBOutlet weak var numberOfVisitedPlaceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ProfileInfoView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}

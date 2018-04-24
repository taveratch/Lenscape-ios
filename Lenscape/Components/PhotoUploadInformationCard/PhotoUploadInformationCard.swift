//
//  PhotoUploadInformationCard.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 2/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable
class PhotoUploadInformationCard: UIView {

    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var dateTakenView: UIStackView!
    @IBOutlet weak var timeTakenView: UIStackView!
    @IBOutlet weak var seasonView: UIStackView!
    @IBOutlet weak var partOfDayLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var dateTakenLabel: UILabel!
    
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
        let nib = UINib(nibName: "PhotoUploadInformationCard", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    private func commonInit() {
        let view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

}

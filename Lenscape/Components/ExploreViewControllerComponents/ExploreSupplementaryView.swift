//
//  SupplementaryView.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 19/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable
class ExploreSupplementaryView: UICollectionReusableView {

    @IBOutlet weak var switchViewToMap: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tabHeader: TabHeader!
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
        let nib = UINib(nibName: "ExploreSupplementaryView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    private func commonInit() {
        let view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        self.progressView.progress = 0
        self.progressView.isHidden = true
    }

}

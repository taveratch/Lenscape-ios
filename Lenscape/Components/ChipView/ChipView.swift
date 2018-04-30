//
//  ChipView.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 30/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable
class ChipView: UIView {

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
        let nib = UINib(nibName: "ChipView", bundle: bundle)
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

//
//  CustomView.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 19/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class CustomView: UIView {
    
    var filename: String?
    init(filename: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        commonInit(filename: filename)
        self.filename = filename
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(filename: filename!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(filename: filename!)
    }
    
    func loadViewFromNib(_ filename: String) -> UIView {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: filename, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    private func commonInit(filename: String) {
        let view = loadViewFromNib(filename)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

}

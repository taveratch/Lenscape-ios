//
//  CircularScrollViewItem.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 11/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable class CircularScrollViewItem: UIView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var contentView: GradientView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func instanceFromNib() -> UIView {
        return UINib(nibName: "CircularScrollViewItem", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "CircularScrollViewItem", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    private func commonInit() {
        let view = loadViewFromNib()
        view.frame = self.bounds
        addSubview(view)
//        contentView.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setText(_ text: String) {
        label.text = text
    }

}

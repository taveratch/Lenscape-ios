//
//  ImageCollectionViewCell.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 22/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable
class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
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
        let nib = UINib(nibName: "ImageCollectionViewCell", bundle: bundle)
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

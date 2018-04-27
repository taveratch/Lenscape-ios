//
//  UIScrollView.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

extension UIScrollView {
    
    func isZoomable(active: Bool, minScale: CGFloat? = 1.0, maxScale: CGFloat? = 6.0 ) {
        if active {
            self.minimumZoomScale = minScale!
            self.maximumZoomScale = maxScale!
        } else {
            self.minimumZoomScale = 1
            self.maximumZoomScale = 1
        }
    }
    
    func doubleTapZoom(pointInView: CGPoint) {
        
        let newZoomScale = self.zoomScale == 1 ? CGFloat(3) : CGFloat(1)
        
        let scrollViewSize = self.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (width/2)
        let y = pointInView.y - (height/2)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: width, height: height)
        
        self.zoom(to: rectToZoomTo, animated: true)
    }
}

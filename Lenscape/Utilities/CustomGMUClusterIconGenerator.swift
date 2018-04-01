//
//  CustomGMUClusterIconGenerator.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 1/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class CustomGMUClusterIconGenerator: GMUDefaultClusterIconGenerator {
    
    override func icon(forSize size: UInt) -> UIImage {
        let image = textToImage(drawText: String(size) as NSString,
                                inImage: UIImage(named: "Maps Cluster")!,
                                font: UIFont.boldSystemFont(ofSize: 16))
        return image
    }
    
    private func textToImage(drawText text: NSString, inImage image: UIImage, font: UIFont) -> UIImage {
        
        let height: CGFloat = 50
        let width: CGFloat = 50
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.center
        let textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let attributes=[
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.paragraphStyle: textStyle,
            NSAttributedStringKey.foregroundColor: textColor]
        
        // vertically center (depending on font)
        let textH = font.lineHeight
        let textY = (height-textH)/2
        let textRect = CGRect(x: 0, y: textY, width: width, height: textH)
        text.draw(in: textRect.integral, withAttributes: attributes)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

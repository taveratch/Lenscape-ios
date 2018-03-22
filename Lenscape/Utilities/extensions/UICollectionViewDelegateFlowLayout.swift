////
////  UICollectionViewDelegateFlowLayout.swift
////  Lenscape
////
////  Created by TAWEERAT CHAIMAN on 22/3/2561 BE.
////  Copyright © 2561 Lenscape. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//extension UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemsPerRow = 3
//        print(collectionView.frame.size.width)
//        let availableWidth = collectionView.frame.size.width - CGFloat(itemsPerRow+1)
//        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
//        return CGSize(width: widthPerItem, height: widthPerItem)
//    }
//
//    //Space between column
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.5
//    }
//
//    // Space between row
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 2
//    }
//
//    // Remove margin of UICollectionView not cell.
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//}


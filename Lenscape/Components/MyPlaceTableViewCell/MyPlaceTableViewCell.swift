//
//  MyPlaceTableViewCell.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 26/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class MyPlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var placeNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        photoCollectionView.delegate = dataSourceDelegate
        photoCollectionView.dataSource = dataSourceDelegate
        photoCollectionView.tag = row
        photoCollectionView.reloadData()
    }

}

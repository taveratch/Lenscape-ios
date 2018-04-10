//
//  SearchAutoCompleteTableViewCell.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class SearchAutoCompleteTableViewCell: UITableViewCell {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

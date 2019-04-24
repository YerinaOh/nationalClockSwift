//
//  SearchTableViewCell.swift
//  nationalClockSwift
//
//  Created by OHYERINA on 24/04/2019.
//  Copyright © 2019 OHYERINA. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var searchTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func selectedAction(_ sender: Any) {
    }
    
}

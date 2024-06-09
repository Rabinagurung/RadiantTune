//
//  RTSearchStationTableViewCell.swift
//  RadiantTune
//
//  Created by Elvis Nguyen on 2024-06-09.
//

import UIKit

class RTSearchStationTableViewCell: UITableViewCell {

    @IBOutlet weak var imgStationFavicon: UIImageView!
    @IBOutlet weak var lblStationName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

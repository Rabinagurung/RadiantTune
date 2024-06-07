//
//  RTFavoriteStationCell.swift
//  RadiantTune
//
//  Created by Aaribna Gurung on 5/29/24.
//

import UIKit


protocol RTFavoriteStationCellDelegate: AnyObject {
    func didPressFavoriteButton(at indexPath: IndexPath, completion: @escaping () -> Void)
}
class RTFavoriteStationCell: UITableViewCell {
    
    weak var delegate: RTFavoriteStationCellDelegate?
    var indexPath: IndexPath?

    @IBOutlet weak var favroiteButton: UIButton!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stationName.textColor = UIColor.label
        detailLabel.textColor = UIColor.secondaryLabel
        favroiteButton.setTitle("", for: .normal)
        
    }

   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        sender.alpha = 0.5
        
        if let indexPath = self.indexPath {
            delegate?.didPressFavoriteButton(at: indexPath) {
        
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    sender.alpha = 1.0
                }
            }
        }
    }
}

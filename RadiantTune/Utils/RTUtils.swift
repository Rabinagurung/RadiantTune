//
//  RTUtils.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-13.
//

import Foundation
import UIKit


///screen Width
let kScreenWidth = UIScreen.main.bounds.size.width
///screen Height
let kScreenHeight = UIScreen.main.bounds.size.height





// station name font
func stationNameFont(label: UILabel) -> UILabel {
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    return label
}

// station tags font
func stationTagFont(label: UILabel) -> UILabel {
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    return label
}


func showHUDWithMessege(messege: String) {
    SVProgressHUD.showError(withStatus: messege)
}



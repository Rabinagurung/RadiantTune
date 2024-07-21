//
//  RTUtils.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-13.
//

import Foundation
import UIKit

struct Constants {
    // MARK: - Reuse identifier for the FavoriteTableViewCell
    static let favoriteTableViewCell = "FavoriteTableViewCell"
    static let FavoritesUpdated = "FavoritesUpdated"
    
    static let StationPlaying = "StationPlaying"
    static let StationStopped = "StationStopped"

    
    // MARK: - Last played station UserDefaults key
    static let LastPlayedStationKey = "LastPlayedStation"
    static let AutoPlayEnabled = "AutoPlayEnabled"
    

}

struct Search {
    static let SearchByStationsText = "Search by Radio Stations"
    static let SearcyByTagText = "Search by Tags/Genre"
}


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


func showHUDWithError(message: String) {
    SVProgressHUD.showError(withStatus: message)
    SVProgressHUD.dismiss(withDelay: 1.0)
}

func showHUDWithSuccess(message: String) {
    SVProgressHUD.showSuccess(withStatus: message)
    SVProgressHUD.dismiss(withDelay: 1.0)
}

func isValidURLString(url: String) -> Bool {
    return !url.isEmpty && url.contains("http")
}


import Lottie

// Setup Lottie animation
func setupLottieAnimation(_ animationView: LottieAnimationView, withName name: String, speed: CGFloat = 1.0, loopMode: LottieLoopMode = .loop, contentMode: UIView.ContentMode = .scaleAspectFit) {
    animationView.animation = LottieAnimation.named(name)
    animationView.contentMode = contentMode
    animationView.loopMode = loopMode
    animationView.animationSpeed = speed
}

func setupPlayerWidgetConstraints(in viewController: UIViewController, playerWidget: UIView) {
    playerWidget.translatesAutoresizingMaskIntoConstraints = false
    viewController.view.addSubview(playerWidget)
    guard let superview = playerWidget.superview else { return }
    
    // Constraints
    let heightConstraint = playerWidget.heightAnchor.constraint(equalToConstant: 70)
    let leadingConstraint = playerWidget.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16)
    let trailingConstraint = playerWidget.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16)
    let bottomConstraint = playerWidget.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)  // Adjusted for safe area
    
    // Activate all constraints
    NSLayoutConstraint.activate([
        heightConstraint,
        leadingConstraint,
        trailingConstraint,
        bottomConstraint
    ])
}


func base64String(originalString: String) -> String? {
    // Convert the string to Data
    if let data = originalString.data(using: .utf8) {
        // Encode the data to Base64
        let base64EncodedString = data.base64EncodedString()
        return base64EncodedString
    } else {
        return nil
    }
}

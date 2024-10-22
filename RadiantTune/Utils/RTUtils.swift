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
    static let RecentlyPlayedStationsKey = "RecentlyPlayedStationsKey"
    

}

struct Search {
    static let SearchByStationsText = "Search by Radio Stations"
    static let SearchByCountryText = "Search Radio Stations by Country"
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

func setupPlayerWidgetConstraints(in viewController: UIViewController, playerWidget: UIView, topPadding: CGFloat = 16, bottomPadding: CGFloat = 16) {
    playerWidget.translatesAutoresizingMaskIntoConstraints = false
    viewController.view.addSubview(playerWidget)
    guard let superview = playerWidget.superview else { return }
    

    let heightConstraint = playerWidget.heightAnchor.constraint(equalToConstant: 70)
    let leadingConstraint = playerWidget.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
    let trailingConstraint = playerWidget.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
    let bottomConstraint = playerWidget.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor) // No extra padding needed
    
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


let supportedFormats = ["png", "jpg", "jpeg"]
let zoomerUUID = "cce309bf-7005-422a-a097-a38bf7a0f51b"

func setImageForImageView(_ imageView: UIImageView, with urlString: String, for id: String) {
    if id == zoomerUUID && UITraitCollection.current.userInterfaceStyle == .dark {
        imageView.image = UIImage(named: "default_station.jpg")
        return
    }
    
    if let url = URL(string: urlString) {
        let fileExtension = url.pathExtension.lowercased()
        
        if supportedFormats.contains(fileExtension) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "default_station.jpg"))
        } else {
            imageView.image = UIImage(named: "default_station.jpg")
        }
    } else {
        imageView.image = UIImage(named: "default_station.jpg")
    }
}

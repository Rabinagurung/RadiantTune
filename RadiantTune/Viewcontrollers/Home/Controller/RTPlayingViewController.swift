//
//  RTPlayingViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-28.
//

import UIKit

protocol RTPlayingViewControllerDelegate {
    func controllerDidClosed(station: Station?)
}


class RTPlayingViewController: RTBaseViewController {
    
    var delegate: RTPlayingViewControllerDelegate?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    var station: Station?
    var playerState: STKAudioPlayerState = STKAudioPlayerState.stopped

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // hide HUD
        SVProgressHUD.dismiss()
        
        // if the player is playing it should call the delegate to refresh the widget
        if playBtn.isSelected {
            delegate?.controllerDidClosed(station: station)
        }
    }
    
    private func setupUI() {
        playBtn.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playBtn.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        favoriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteBtn.setImage(UIImage(systemName: "star.fill"), for: .selected)
        
        
        playBtn.setTitle("", for: .normal)
        playBtn.setTitle("", for: .selected)
        favoriteBtn.setTitle("", for: .normal)
        favoriteBtn.setTitle("", for: .selected)
        
    }
    
    private func configData() {
        // icon View
        if let station = station {
            iconImageView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(named: "default_station.jpg"))
            
            // title Label
            nameLabel.text = station.name
            
            // sub Label
            subLabel.text = station.country + "|" + station.tags
            
            // whether is the previous station
            if RTAudioPlayer.shared.currentURL == station.url {
                // the same, set the button's state
                if RTAudioPlayer.shared.playerState == .playing {
                    playBtn.isSelected = true
                } else {
                    playBtn.isSelected = false
                }
            }
        }
    }
    
    @objc
    @IBAction func playAction(sender: UIButton) {
        if let station = station {
            if(sender.isSelected) {
                // to stop
                RTAudioPlayer.shared.stop()
            } else {
                // to play
                RTAudioPlayer.shared.playWith(url: station.url)
                RTAudioPlayer.shared.delegate = self
            }
        }
        playBtn.isSelected = !playBtn.isSelected
        
    }
    @IBAction func favoriteAction(_ sender: UIButton) {
        if let station = station {
            RTDatabaseManager.shared.addFavorite(station: convertStationToFavorite(station: station))
            sender.isSelected = true
        }
    }
}

//MARK:- Audio Delegate
extension RTPlayingViewController: RTAudioPlayerDelegate {
    func playerStateDidChanged(state: STKAudioPlayerState) {
        playerState = state
        if state == .playing {
            SVProgressHUD.dismiss()
            playBtn.isSelected = true
        } else if state == .buffering {
            SVProgressHUD.show()
        } else if state == .error {
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "load error")
            playBtn.isSelected = false
        } else {
            playBtn.isSelected = false
        }
    }
    
}

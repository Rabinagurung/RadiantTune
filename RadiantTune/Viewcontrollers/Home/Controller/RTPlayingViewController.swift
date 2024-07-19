//
//  RTPlayingViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-28.
//

import UIKit
import Lottie
import MediaPlayer

protocol RTPlayingViewControllerDelegate {
    func controllerDidClosed(station: Station?)
}


class RTPlayingViewController: RTBaseViewController {
    @IBOutlet weak var animationView: LottieAnimationView!
    
    var delegate: RTPlayingViewControllerDelegate?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    var station: Station?
    var playerState: STKAudioPlayerState = STKAudioPlayerState.stopped
    private var isFavorite: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimationView()
        setupUI()
        checkIfStationIsFavorite(uuid: station?.stationuuid)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // hide HUD
        SVProgressHUD.dismiss()
        
        delegate?.controllerDidClosed(station: station)
    }
    
    private func setupAnimationView() {
        setupLottieAnimation(animationView, withName: "wave", speed: 1.5)
    }
    
    
    private func setupUI() {
        playBtn.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playBtn.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        
        
        playBtn.setTitle("", for: .normal)
        playBtn.setTitle("", for: .selected)
        favoriteBtn.setTitle("", for: .normal)
        favoriteBtn.setTitle("", for: .selected)
        
        setupAirPlay()
        
    }
    
    private func checkIfStationIsFavorite(uuid: String?) {
        
        guard let uuid = station?.stationuuid else { return }
        
        // Move database check to a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let isFavorite = RTDatabaseManager.shared.isFavoriteStation(uuid: uuid)
            
            DispatchQueue.main.async {
                self.isFavorite = isFavorite
                self.configData()
            }
        }
    }
    
    
    private func configData() {
        
        // icon View
        if let station = station {
            
            
            if(isFavorite) {
                favoriteBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                favoriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
            }
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
                    animationView.play()
                } else {
                    playBtn.isSelected = false
                    animationView.stop()
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
                animationView.stop()
            } else {
                // to play
                RTAudioPlayer.shared.playWith(url: station.url)
                RTAudioPlayer.shared.delegate = self
            }
        }
        playBtn.isSelected = !playBtn.isSelected
        
    }
    
    func setupAirPlay() {
        let volumeView = MPVolumeView(frame: CGRect(x: 80, y: CGRectGetMinY(playBtn.frame), width: 100, height: 50))
        volumeView.showsVolumeSlider = false // Hide the volume slider if you only want the AirPlay button
        self.view.addSubview(volumeView)
        volumeView.backgroundColor = .blue
        self.view.bringSubviewToFront(volumeView)
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        if let station = station {
            
            RTAnimationUtility.favroiteButton(view: sender)
            DispatchQueue.global(qos: .userInitiated).async {
                let newFavoriteStatus = !self.isFavorite
                
                if newFavoriteStatus {
                    RTDatabaseManager.shared.addFavorite(station: station)
                } else {
                    RTDatabaseManager.shared.deleteFavoriteByUUID(stationUUID: station.stationuuid)
                }
                
                DispatchQueue.main.async {
                    // Optimistically update the UI
                    
                    self.isFavorite = newFavoriteStatus
                    let uiImage = newFavoriteStatus ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    self.favoriteBtn.setImage(uiImage, for: .normal)
                    // Notify to favorite screen that the favorite stations have been updated
                    NotificationCenter.default.post(name: NSNotification.Name(Constants.FavoritesUpdated), object: nil)
                    
                }
            }
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
            animationView.play()
            
        } else if state == .buffering {
            SVProgressHUD.show()
            animationView.stop()
        } else if state == .error {
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "load error")
            playBtn.isSelected = false
            animationView.stop()
        } else {
            playBtn.isSelected = false
            animationView.stop()
        }
    }
    
}

//
//  RTPlayerWidgetView.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-31.
//

import UIKit
import Lottie

protocol RTPlayerWidgetViewDelegate {
    func clickIconImageView(station: Station?)
}


class RTPlayerWidgetView: UIView {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    var station: Station?
    
    var delegate: RTPlayerWidgetViewDelegate?
    
    @IBOutlet var contentView:UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    static let shared = RTPlayerWidgetView()
    var isFavorite: Bool = false
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
     
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func playerPlaying() {
        animationView.play()
        
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playButton.isSelected = true
    }
    
    
    
    @objc private func playerStop() {
        animationView.stop()
        
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playButton.isSelected = false
    }
    
    

    func commonInit() {
        // 加载XIB文件
        Bundle.main.loadNibNamed("RTPlayerWidgetView", owner: self, options: nil)
        addSubview(contentView)
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        saveButton.setImage(UIImage(systemName: "star"), for: .normal)
        saveButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        
        playButton.setTitle("", for: .normal)
        playButton.setTitle("", for: .selected)
        saveButton.setTitle("", for: .normal)
        saveButton.setTitle("", for: .selected)
        contentView.frame = self.bounds
        
        // add gesture to iconview
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(iconImageViewAction))
        iconImageView.isUserInteractionEnabled = true
        iconImageView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlaying), name: NSNotification.Name(Constants.StationPlaying), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerStop), name: NSNotification.Name(Constants.StationStopped), object: nil)
        
        setupLottieAnimation(animationView, withName: "wave")
        
    }
    
    
    func checkIfStationIsFavorite() {
        guard let uuid = station?.stationuuid else { return }
        isFavorite = RTDatabaseManager.shared.isFavoriteStation(uuid: uuid)
        let imageName = isFavorite ? "star.fill" : "star"
        saveButton.setImage(UIImage(systemName: imageName), for: .normal)
        
    }
    
    
    
    // refresh widget state
    func refreshState(station: Station?) {
        
        let playerState = RTAudioPlayer.shared.playerState
        if station != nil {
            self.station = station
            
        }
        checkIfStationIsFavorite()
        
        if (playerState == .playing) {
            playButton.isSelected = true
            animationView.play()
        } else {
            playButton.isSelected = false
            animationView.stop()
        }
        if let station = station {
            // icon Image View
            iconImageView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(named: "default_station.jpg"))
            
            // title Label
            stationNameLabel.text = station.name
            
            // sub Label
            tagsLabel.text = station.country + "|" + station.tags
            
            if (playerState == .playing) {
                playButton.isSelected = true
                animationView.play()
            } else {
                playButton.isSelected = false
                animationView.stop()
            }
        }
    }
    
    
    @objc
    func iconImageViewAction() {
        delegate?.clickIconImageView(station: station)
    }
    
    
    @IBAction func playStopAction(_ sender: UIButton) {
       
        if let station = station {
            if(sender.isSelected) {
                // to stop
                RTAudioPlayer.shared.stop()
                NotificationCenter.default.post(name: NSNotification.Name(Constants.FavoritesUpdated), object: nil)
                animationView.stop()
            } else {
                // to play
                RTAudioPlayer.shared.playWith(url: station.url)
                saveLastPlayedStation(station)
                print("Station saved: \(station.name)")
                animationView.play()
            }
            sender.isSelected = !sender.isSelected
            
        }
    }
    
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        if let station = station {
            
            if(!self.isFavorite) {
                RTAnimationUtility.favroiteButton(view: sender)
            }
            
            let newFavoriteStatus = !self.isFavorite
            sender.isEnabled = false;
            DispatchQueue.global(qos: .userInitiated).async {
                
                if newFavoriteStatus {
                    RTDatabaseManager.shared.addFavorite(station: station)
                } else {
                    RTDatabaseManager.shared.deleteFavoriteByUUID(stationUUID: station.stationuuid)
                }
                
                DispatchQueue.main.async {
                    
                    self.isFavorite = newFavoriteStatus
                    let uiImage = newFavoriteStatus ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    self.saveButton.setImage(uiImage, for: .normal)
                    NotificationCenter.default.post(name: NSNotification.Name(Constants.FavoritesUpdated), object: nil)
                    sender.isEnabled = true
                    
                }
            }
        }
    }
    
    private func saveLastPlayedStation(_ station: Station) {
        RTLastPlayedStationManager.saveLastPlayedStation(station)
    }
    
}




//
//  RTPlayerWidgetView.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-31.
//

import UIKit


protocol RTPlayerWidgetViewDelegate {
    func clickIconImageView(station: Station?)
}

class RTPlayerWidgetView: UIView {
    
    var station: Station?
    
    var delegate: RTPlayerWidgetViewDelegate?
    @IBOutlet var contentView:UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    static let shared = RTPlayerWidgetView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
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
    }
    
    // refresh widget state
    func refreshState(station: Station?) {
        let playerState = RTAudioPlayer.shared.playerState
        if station != nil {
            self.station = station
        }
        
        if (playerState == .playing) {
            playButton.isSelected = true
        } else {
            playButton.isSelected = false
        }
        if let station = station {
            // icon Image View
            iconImageView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(named: "default_station.jpg"))
            
            // title Label
            stationNameLabel.text = station.name
            
            // sub Label
            tagsLabel.text = station.country + "|" + station.tags
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
            } else {
                // to play
                RTAudioPlayer.shared.playWith(url: station.url)
            }
            sender.isSelected = !sender.isSelected
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        if let station = station {
            RTDatabaseManager.shared.addFavorite(station: convertStationToFavorite(station: station))
            sender.isSelected = true
        }
    }
    
}

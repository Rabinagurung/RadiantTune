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
        playButton.setTitle(NSLocalizedString("player_button_play", comment: ""), for: .normal)
        playButton.setTitle(NSLocalizedString("player_button_stop", comment: ""), for: .selected)
        contentView.frame = self.bounds
        
        // add gesture to iconview
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(iconImageViewAction))
        iconImageView.isUserInteractionEnabled = true
        iconImageView.addGestureRecognizer(tapGesture)
    }
    
    // refresh widget state
    func refreshState(station: Station?) {
        let playerState = RTAudioPlayer.shared.playerState
        self.station = station
        
        if (playerState == .playing) {
            playButton.isSelected = true
        } else {
            playButton.isSelected = false
        }
        if let station = station {
            guard let url = URL(string: station.favicon) else {
                return
            }
            // icon Image View
            iconImageView.kf.setImage(with: url)
            
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
}

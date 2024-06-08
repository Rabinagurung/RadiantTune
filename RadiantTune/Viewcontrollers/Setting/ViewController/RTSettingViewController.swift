//
//  RTSettingViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit

class RTSettingViewController: RTBaseViewController {
    
    @IBOutlet weak var playerWidgetView: RTPlayerWidgetView!
    
    @IBOutlet weak var sleepTimerSwitch: UISwitch!
    @IBOutlet weak var setTimerBtn: UIButton!
    
    
    var hour: Int?
    var minute: Int?
    private let segueSleepTimer = "goToSleepTimerScreen"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let station = RTDatabaseManager.shared.activeStation {
            playerWidgetView.station = station
            playerWidgetView.refreshState(station: station)
            playerWidgetView.isHidden = false
        } else {
            playerWidgetView.isHidden = true
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerWidgetConstraints()
    
        let switchValue = UserDefaults.standard.bool(forKey: "Switch")
        sleepTimerSwitch.isOn = switchValue
        
        if switchValue == true {
            setRadioTimer()
        }
        
    }
    
    @IBAction func onEditTapped(_ sender: UIButton) {
        performSegue(withIdentifier: segueSleepTimer, sender: self)
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: "Switch")
            setTimerBtn.isHidden = false
            setRadioTimer()
        } else {
            UserDefaults.standard.setValue(false, forKey: "Switch")
            setTimerBtn.isHidden = true
        }
    }
    
    func setRadioTimer() {
        hour = UserDefaults.standard.integer(forKey: "Hour")
        minute = UserDefaults.standard.integer(forKey: "Minute")
        
        //Add and convert time interval into seconds
        var timeLeft = ((hour ?? 0)*60*60) + ((minute ?? 0)*60)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            timeLeft -= 1
            
            if(timeLeft == 0) {
                timer.invalidate()
                RTAudioPlayer.shared.stop()
            }
        }

    }
    private func setupPlayerWidgetConstraints() {
        
        playerWidgetView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(playerWidgetView)
        guard let superview = playerWidgetView.superview else { return }
        
        // Constraints
        let heightConstraint = playerWidgetView.heightAnchor.constraint(equalToConstant: 70)
        let leadingConstraint = playerWidgetView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16)
        let trailingConstraint = playerWidgetView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16)
        let bottomConstraint = playerWidgetView.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)  // Adjusted for safe area
        
        // Activate all constraints
        NSLayoutConstraint.activate([
            heightConstraint,
            leadingConstraint,
            trailingConstraint,
            bottomConstraint
        ])

    }
}

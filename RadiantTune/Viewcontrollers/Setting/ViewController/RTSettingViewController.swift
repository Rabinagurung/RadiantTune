//
//  RTSettingViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit

class RTSettingViewController: RTBaseViewController {
    
    
    @IBOutlet weak var sleepTimerSwitch: UISwitch!
    @IBOutlet weak var setTimerBtn: UIButton!
    var hour: Int?
    var minute: Int?
    private let segueSleepTimer = "goToSleepTimerScreen"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
}

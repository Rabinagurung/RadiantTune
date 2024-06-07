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
    }
    
    @IBAction func onEditTapped(_ sender: UIButton) {
        performSegue(withIdentifier: segueSleepTimer, sender: self)
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: "Switch")
            setTimerBtn.isHidden = false
        } else {
            UserDefaults.standard.setValue(false, forKey: "Switch")
            setTimerBtn.isHidden = true
        }
    }
}

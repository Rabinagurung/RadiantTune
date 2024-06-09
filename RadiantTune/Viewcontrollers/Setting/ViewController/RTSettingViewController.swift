//
//  RTSettingViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit

class RTSettingViewController: RTBaseViewController, RTSleepTimerDelegate {
    
    @IBOutlet weak var sleepTimerSwitch: UISwitch!
    @IBOutlet weak var setTimerBtn: UIButton!
    var currentTimer: Timer?
    var hour: Int?
    var minute: Int?
    private let segueSleepTimer = "goToSleepTimerScreen"
    var isTimerSet: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSwitchValue()
        
    }
    
    @IBAction func onEditTapped(_ sender: UIButton) {
        performSegue(withIdentifier: segueSleepTimer, sender: self)
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: "Switch")
            setTimerBtn.isHidden = false
            setRadioTimer()
            isTimerSet = true
        } else {
            UserDefaults.standard.setValue(false, forKey: "Switch")
            setTimerBtn.isHidden = true
            isTimerSet = false
            invalidateCurrentTimer()
        }
    }
    
    func setRadioTimer() {
        
        invalidateCurrentTimer()
        
        hour = UserDefaults.standard.integer(forKey: "Hour")
        minute = UserDefaults.standard.integer(forKey: "Minute")
        
        //Add and convert time interval into seconds
        var timeLeft = ((hour ?? 0)*60*60) + ((minute ?? 0)*60)
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            timeLeft -= 1
            print(timeLeft)
            
            guard self.isTimerSet == true else {
                timer.invalidate()
                return
            }
            
            if(timeLeft == 0) {
                timer.invalidate()
                RTAudioPlayer.shared.stop()
                RTPlayerWidgetView().playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .selected)
            }
        }
    }
    
    func invalidateCurrentTimer() {
        currentTimer?.invalidate()
        currentTimer = nil
    }
    
    func loadSwitchValue() {
        let switchValue = UserDefaults.standard.bool(forKey: "Switch")
        sleepTimerSwitch.isOn = switchValue
        
        if switchValue == true {
            setRadioTimer()
        } else {
            setTimerBtn.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueSleepTimer,
           let destinationVC = segue.destination as? RTSleepTimerViewController {
            destinationVC.delegate = self
        }
    }
    
    func didUpdateTimer() {
        setRadioTimer()
    }
}

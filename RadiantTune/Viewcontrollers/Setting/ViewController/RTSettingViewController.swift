//
//  RTSettingViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit
import SwiftUI

class RTSettingViewController: RTBaseViewController, RTSleepTimerDelegate {
    
    @IBOutlet weak var  autoPlaySwitch: UISwitch!
    @IBOutlet weak var playerWidgetView: RTPlayerWidgetView!
    @IBOutlet weak var sleepTimerSwitch: UISwitch!
    @IBOutlet weak var setTimerBtn: UIButton!
    private var mySwiftUIView: RTAddStationView?
    var currentTimer: Timer?

    var hour: Int?
    var minute: Int?
    private let segueSleepTimer = "goToSleepTimerScreen"
    var isTimerSet: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configStation()
        updateAutoPlaySwitch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerWidgetConstraints(in: self, playerWidget: playerWidgetView)
    
        let switchValue = UserDefaults.standard.bool(forKey: "Switch")
        sleepTimerSwitch.isOn = switchValue
        
        if switchValue == true {
            setRadioTimer()
        }
        loadSwitchValue()
        
    }
    
    private func configStation () {
        if let station = RTDatabaseManager.shared.activeStation {
            playerWidgetView.station = station
            playerWidgetView.refreshState(station: station)
            playerWidgetView.isHidden = false
        } else {
            playerWidgetView.isHidden = true
        }
        
    }
    
    private func updateAutoPlaySwitch() {
        autoPlaySwitch.isOn = RTLastPlayedStationManager.isAutoPlayEnabled()
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
    
    @IBAction func onAutoPlaySwitchChanged(_ sender: UISwitch) {
        RTLastPlayedStationManager.setAutoPlayEnabled(sender.isOn)
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
                
                //Update UI after timer is up
                RTPlayerWidgetView.shared.refreshState(station: nil)
                

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
    @IBAction func pushToAddStationAction(_ sender: UIButton) {
        let swiftUIViewController = RTAddStationController(rootView: RTAddStationView())
        swiftUIViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(swiftUIViewController, animated: true)
    }
    
    
}



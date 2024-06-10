//
//  RTSleepTimerViewController.swift
//  RadiantTune
//
//  Created by Joyceline Nathaniel on 2024-06-06.
//

import UIKit

class RTSleepTimerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var sleepTimerPicker: UIPickerView!
    
    var pickerData: [[String]] = []
    
    var hour: Int = 0
    var minute: Int = 0
    
    weak var delegate: RTSleepTimerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Connect data to picker
        self.sleepTimerPicker.delegate = self
        self.sleepTimerPicker.dataSource = self
        
        hour = UserDefaults.standard.integer(forKey: "Hour")
        minute = UserDefaults.standard.integer(forKey: "Minute")
        
        //Set values of picker
        sleepTimerPicker.selectRow(hour, inComponent: 0, animated: false)
        sleepTimerPicker.selectRow(minute, inComponent: 1, animated: false)
        
    }
    @IBAction func onSaveTapped(_ sender: UIButton) {
        UserDefaults.standard.set(hour, forKey: "Hour")
        UserDefaults.standard.set(minute, forKey: "Minute")
        UserDefaults.standard.synchronize()
        
        delegate?.didUpdateTimer()
        dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        case 1:
            return 60
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            if row == 1 {
                return "\(row) hour"
            } else {
                return "\(row) hours"
            }
        case 1:
            return "\(row) min"
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = row
            return
        case 1:
            minute = row
            return
        default:
            return
        }
        
    }

}

// Define the delegate protocol
protocol RTSleepTimerDelegate: AnyObject {
    func didUpdateTimer()
}

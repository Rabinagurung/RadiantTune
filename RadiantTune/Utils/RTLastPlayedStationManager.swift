//
//  RTLastPlayedStationManager.swift
//  RadiantTune
//
//  Created by Aaribna Gurung on 6/11/24.
//

import Foundation


class RTLastPlayedStationManager {
    
    
    static func setAutoPlayEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Constants.AutoPlayEnabled)
    }
    
    static func isAutoPlayEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.AutoPlayEnabled)
    }
    
    static func saveLastPlayedStation(_ station: Station) {
        let defaults = UserDefaults.standard
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(station)
            defaults.set(data, forKey: Constants.LastPlayedStationKey)
        } catch {
            print("Failed to encode station: \(error)")
        }
      
    }
    
    static func loadLastPlayedStation() -> Station? {
        if let data = UserDefaults.standard.data(forKey: Constants.LastPlayedStationKey) {
            do {
                let decoder = JSONDecoder()
                let station = try decoder.decode(Station.self, from: data)
                return station
            } catch {
                print("Failed to decode station: \(error)")
            }
        }
        return nil
    }
}

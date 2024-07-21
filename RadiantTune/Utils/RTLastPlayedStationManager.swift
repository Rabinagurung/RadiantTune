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
        
        saveRecentlyPlayedStation(station)
      
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
    
    //Saves a recently played station into the list of recently played stations
    static func saveRecentlyPlayedStation(_ station: Station) {
        var recentStations = loadRecentlyPlayedStations()
        
        //Removes duplicate stations on recently played list
        if let index = recentStations.firstIndex(where: { $0.stationuuid == station.stationuuid }) {
            recentStations.remove(at: index)
        }
        
        //Inserts new station
        recentStations.insert(station, at: 0)
        
        //Removes least recent so that only the first three most recently played stations are shown
        if recentStations.count > 3 {
            recentStations.removeLast()
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentStations)
            UserDefaults.standard.set(data, forKey: Constants.RecentlyPlayedStationsKey)
        } catch {
            print("Failed to encode recent stations: \(error)")
        }
    }
    
    //Decodes all recently played stations stored in user defaults if any
    static func loadRecentlyPlayedStations() -> [Station] {
        if let data = UserDefaults.standard.data(forKey: Constants.RecentlyPlayedStationsKey) {
            do {
                let decoder = JSONDecoder()
                let stations = try decoder.decode([Station].self, from: data)
                return stations
            } catch {
                print("Failed to decode recent stations: \(error)")
            }
        }
        return []
    }
}

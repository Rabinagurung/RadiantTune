//
//  AppDelegate.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit
import AVKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

//
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DispatchQueue.global(qos: .userInitiated).async {
            RTDatabaseManager.shared.populateFavoriteUUIDs()
        }
        
        
        playLastPlayedStation()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch  {
            
        }
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

 
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveCurrentStationState()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveCurrentStationState()
    }
    
    private func playLastPlayedStation() {
        // Load the last played station from UserDefaults
        if let lastPlayedStation = RTLastPlayedStationManager.loadLastPlayedStation() {
            // Update the active station and UI state first
            RTDatabaseManager.shared.activeStation = lastPlayedStation
            RTPlayerWidgetView.shared.station = lastPlayedStation
            
            // Check if auto-play is enabled and start playback if it is
            if RTLastPlayedStationManager.isAutoPlayEnabled() {
                RTAudioPlayer.shared.playWith(url: lastPlayedStation.url)
            }
        }
    }
    
    private func saveCurrentStationState() {
        
        if let station = RTDatabaseManager.shared.activeStation {
            RTLastPlayedStationManager.saveLastPlayedStation(station)
        }
    }
}


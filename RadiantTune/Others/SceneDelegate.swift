//
//  SceneDelegate.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit
import Lottie
import AVFoundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        showLottieSplashScreen()
    }
    private func showLottieSplashScreen() {
        guard let window = window else { return }
        
        // Read the user preference from UserDefaults
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if isDarkMode {
            window.overrideUserInterfaceStyle = .dark
        } else {
            window.overrideUserInterfaceStyle = .light
        }
        // Create a container view
        let containerView = UIView(frame: window.bounds)
        containerView.backgroundColor = isDarkMode ? .black : .white // Set background color as needed
        window.addSubview(containerView)
        
     
        let animationView = LottieAnimationView(name: "radio") // Replace with your file name
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.75
        
        containerView.addSubview(animationView)
        
        // Add Auto Layout constraints to center the animation view and maintain aspect ratio
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor, multiplier: 0.8) // Adjust this multiplier to match your animation's aspect ratio
        ])
        playSound(named: "splash-sound")
        animationView.play { (finished) in
            // Remove the splash screen after the animation finishes
            containerView.removeFromSuperview()
            // Transition to your main view controller
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainViewController = mainStoryboard.instantiateInitialViewController() {
                window.rootViewController = mainViewController
                self.playLastPlayedStation()
            }
        }
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
    
    private func playSound(named soundName: String) {
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Failed to play sound: \(error.localizedDescription)")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


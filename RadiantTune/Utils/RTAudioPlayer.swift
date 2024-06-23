//
//  RTPlayer.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-28.
//

import Foundation
import AVFoundation

protocol RTAudioPlayerDelegate {
    func playerStateDidChanged(state: STKAudioPlayerState)
}

class RTAudioPlayer: NSObject {
 
    static let shared = RTAudioPlayer()
    var playerState = STKAudioPlayerState.stopped
    var player: STKAudioPlayer!
    var currentURL: String?
    var delegate: RTAudioPlayerDelegate?
    
    private override init() {
        super.init()
        player = STKAudioPlayer()
        player.delegate = self
     }
    
    func playWith(url: String) {
        currentURL = url
        guard let url = URL(string: url) else {
            
            return
        }
        
        player.play(url)
    }
    
    func stop() {
        player.stop()
    }
    
}

extension RTAudioPlayer: STKAudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {

    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        playerState = state
       
        delegate?.playerStateDidChanged(state: state)
    
        if playerState == .playing {
            NotificationCenter.default.post(name: NSNotification.Name(Constants.FavoritesUpdated), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(Constants.StationPlaying), object: nil)
        }
        
        if playerState == .stopped {
            NotificationCenter.default.post(name: NSNotification.Name(Constants.StationStopped), object: nil)
        }
          
      
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        
        
    }
}


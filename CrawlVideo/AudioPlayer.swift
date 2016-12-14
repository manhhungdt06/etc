//
//  ViewController.swift
//  Music Player
//
//  Created by VietHung on 5/27/16.
//  Copyright © 2016 VietHung. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayer{

    static let sharedInstance = AudioPlayer()
    
    private init() {
    }
    
    var pathString = ""
    var repeating = false
    var playing = false
    var duration = Float()
    var currentTime = Float()
    var titleSong = ""
    var player = AVPlayer()
    var artistName = ""
    var lyric = [Lyric]()
    
    func setupAudio()
    {
       // var url = URL()
        var url: URL
    
        if let checkingUrl = URL(string: pathString)
        {
            url = checkingUrl
        }
        else
        {
            url = URL(fileURLWithPath: pathString)
        }
        let playerItem = AVPlayerItem(url:url)
        player = AVPlayer(playerItem:playerItem)
        player.rate = 1.0;
        player.volume = 0.5
        player.play()
        playing = true
        repeating = true
    }
    
    
    //action
    func Repeat(_ repeatSong: Bool) {
        if(repeatSong == true){
            repeating = true
        }
        else{
            repeating = false
        }
    }
    
    func action_PlayPause() {
        if(playing == false){
            player.play()
            playing = true
        }
        else{
            player.pause()
            playing = false
        }
    }
    func sld_Duration(_ value: Float) {
        let timeToSeek = value * duration
        let time = CMTimeMake(Int64(timeToSeek), 1)
        player.seek(to: time)
    }
    
    func sld_Volume(_ value: Float) {
        player.volume = value
    }
    
    
    
    
    
}


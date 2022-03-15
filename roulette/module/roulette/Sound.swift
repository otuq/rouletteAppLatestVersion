//
//  work1.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/11.
//

import AVFoundation
import UIKit
// ルーレットの音楽
func rouletteSoundSetting(dataSet: RouletteData) {
    var audioPlayer: AVAudioPlayer!
    guard let soundAsset = NSDataAsset(name: dataSet.sound) else {
        print("not found sound data")
        return
    }
    do {
        audioPlayer = try AVAudioPlayer(data: soundAsset.data, fileTypeHint: "wav")
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    } catch {
        print(error.localizedDescription)
        audioPlayer = nil
    }
}

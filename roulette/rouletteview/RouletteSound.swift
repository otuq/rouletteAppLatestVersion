//
//  RouletteSound.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/17.
//
import AVFoundation
import RealmSwift
import UIKit

class RouletteSound {
    static let shared = RouletteSound()
    private var audioPlayer: AVAudioPlayer!
    // ルーレットの音楽
    func rouletteSoundSetting(soundName: String) {
        guard let soundAsset = NSDataAsset(name: soundName) else {
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
    // ルーレット結果の効果音
    func soundEffect(effectName: String) {
        guard let soundAsset = NSDataAsset(name: effectName) else {
            print("not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundAsset.data, fileTypeHint: "wav")
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error.localizedDescription)
            audioPlayer = nil
        }
    }

}

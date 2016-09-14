//
//  PlayerControlsView.swift
//  WBOR
//
//  Created by Ruben on 2/11/16.
//
//
import UIKit
import AVFoundation

class PlayerControlsView: UIView {
    @IBOutlet weak var playButton: UIButton!
    var playing: Bool = false
    var interrupted: Bool = false

    required override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let viewName = "PlayerControlsView"
        let view: UIView = Bundle.main.loadNibNamed(viewName,
            owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerControlsView.audioPlayerInterrupted(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func playButtonTapped() {
        updateButton()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playButtonTapped"), object: nil)
    }
    
    //toggle button play/pause
    func updateButton() {
        self.playing = !self.playing //toggle play state
        
        if self.playing {
            playButton.setBackgroundImage(UIImage(named: "pause.png"), for: UIControlState())
        } else {
            playButton.setBackgroundImage(UIImage(named: "play.png"), for: UIControlState())
        }
    }
    
    //listen for audio player interruption
    func audioPlayerInterrupted(_ notification : Notification) {
        let interruptionDictionary = (notification as NSNotification).userInfo!
        let interruptionType = AVAudioSessionInterruptionType(rawValue: UInt((interruptionDictionary[AVAudioSessionInterruptionTypeKey]! as AnyObject).int32Value))
        
        //audio player was interrupted
        if self.playing && interruptionType == AVAudioSessionInterruptionType.began {
            self.interrupted = true
            updateButton()
        }
        //audio player interruption ended
        if self.interrupted && interruptionType == AVAudioSessionInterruptionType.ended {
            updateButton()
        }
    }
}

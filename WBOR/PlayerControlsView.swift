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
        let view: UIView = NSBundle.mainBundle().loadNibNamed(viewName,
            owner: self, options: nil)[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerControlsView.audioPlayerInterrupted(_:)), name: AVAudioSessionInterruptionNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func playButtonTapped() {
        updateButton()
        NSNotificationCenter.defaultCenter().postNotificationName("playButtonTapped", object: nil)
    }
    
    //toggle button play/pause
    func updateButton() {
        self.playing = !self.playing //toggle play state
        
        if self.playing {
            playButton.setBackgroundImage(UIImage(named: "pause.png"), forState: UIControlState.Normal)
        } else {
            playButton.setBackgroundImage(UIImage(named: "play.png"), forState: UIControlState.Normal)
        }
    }
    
    //listen for audio player interruption
    func audioPlayerInterrupted(notification : NSNotification) {
        let interruptionDictionary = notification.userInfo!
        let interruptionType = AVAudioSessionInterruptionType(rawValue: UInt(interruptionDictionary[AVAudioSessionInterruptionTypeKey]!.intValue))
        
        //audio player was interrupted
        if self.playing && interruptionType == AVAudioSessionInterruptionType.Began {
            self.interrupted = true
            updateButton()
        }
        //audio player interruption ended
        if self.interrupted && interruptionType == AVAudioSessionInterruptionType.Ended {
            updateButton()
        }
    }
}
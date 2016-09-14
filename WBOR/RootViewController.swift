//
//  FirstViewController.swift
//  WBOR
//
//  Created by Ruben Martinez Jr on 9/27/14.
//
//

import Foundation
import MediaPlayer
import AVFoundation
import AudioToolbox
import QuartzCore

class RootViewController : UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var current : UILabel!
    @IBOutlet var currentArtist : UILabel!
    @IBOutlet var record : RMShapedImageView!
    
    var wborURL     = URL(string: "http://139.140.232.18:8000/WBOR")
    var playlistURL = URL(string: "http://wbor-hr.appspot.com/updateinfo")
    var player : AVPlayer?
    var playlist: Playlist?
    var update : Timer?
    var displayOnAir = true
    var playing : Bool = false
    var interrupted : Bool = false
    
    override func viewDidLoad() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.audioPlayerInterrupted(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.togglePlay), name: NSNotification.Name(rawValue: "playButtonTapped"), object: nil)
    }
    
    func rotationDetected(_ rotationGesture: UIRotationGestureRecognizer) {
        if rotationGesture.state == UIGestureRecognizerState.began || rotationGesture.state == UIGestureRecognizerState.changed {
            let rotation = rotationGesture.rotation
            let currentAngle = CGFloat(((record.layer.value(forKeyPath: "transform.rotation.z") as AnyObject).floatValue)!)
            record.layer.setValue(currentAngle + (rotation/10), forKeyPath: "transform.rotation.z")
        }
    }
    
    var recordInterrupted: Bool = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.playing {
            touches.forEach { (touch) -> () in
                let touchPoint = touch.location(in: self.view)
                let imagePoint = record.convert(touchPoint, from: self.view)
                if self.playing && record.point(inside: imagePoint, with: event) {
                    self.stopRecordAnimation()
                    self.recordInterrupted = true
                }
            }
        }
    }
    
    var lastAngle: CGFloat?
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { (touch) -> () in
            let touchPoint = touch.location(in: self.view)
            let imagePoint = record.convert(touchPoint, from: self.view)
            if record.point(inside: imagePoint, with: event) {
                let angle = atan2(touchPoint.y-self.record.center.y, touchPoint.x-self.record.center.x)
                print(record.layer.value(forKeyPath: "transform.rotation.z"))
                let position = CGFloat(((record.layer.value(forKeyPath: "transform.rotation.z") as AnyObject).floatValue)!)
                let nextPosition = position + (angle - (lastAngle ?? angle))
                record.layer.setValue(nextPosition, forKeyPath: "transform.rotation.z")
                
                lastAngle = angle
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.playing && self.recordInterrupted {
            self.startRecordAnimation()
        }
        
        lastAngle = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateInfo(self.playing, buffering: false)
        super.viewWillAppear(animated)
    }
    
    //listen for audio player interruption
    func audioPlayerInterrupted(_ notification : Notification) {
        let interruptionDictionary = (notification as NSNotification).userInfo!
        let interruptionType = AVAudioSessionInterruptionType(rawValue: UInt((interruptionDictionary[AVAudioSessionInterruptionTypeKey]! as AnyObject).int32Value))
        
        //audio player was interrupted
        if interruptionType == AVAudioSessionInterruptionType.began {
            if self.playing {
                self.interrupted = true
                self.togglePlay()
            }
        }
        //audio player interruption ended
        if interruptionType == AVAudioSessionInterruptionType.ended {
            if self.interrupted {
                self.interrupted = false
                self.togglePlay()
            }
        }
    }
    
    //toggle play state on app
    func togglePlay() {
        self.playing = !self.playing //toggle playing
        
        //update player state
        self.updateRecordState(self.playing)
        self.updateInfo(self.playing, buffering: self.playing)
        self.updateStream(self.playing)
    }
    
    //toggle UI for song/artist info
    func updateInfo(_ playing: Bool, buffering: Bool) {
        if playing {
            if self.update != nil {
                self.update!.invalidate()
            }
            current.text = "Buffering..."
            current.isHidden = false
            currentArtist.isHidden = true
            
            if buffering {
                return //don't load playlist info if we're struggling
            }
            
            self.displayPlaylistInfo() //update info
            
            //schedule info update
            self.update = Timer.scheduledTimer(timeInterval: 5,
                target: self,
                selector: #selector(RootViewController.displayPlaylistInfo),
                userInfo: nil,
                repeats: true)
        }
        else {
            if self.update != nil {
                self.update!.invalidate()
            }
            current.isHidden = true
            currentArtist.isHidden = true
        }
    }
    
    //update UI for song/artist info
    func displayPlaylistInfo() {
        if !self.playing {
            current.isHidden = true
            currentArtist.isHidden = true
            return //make sure we don't show anything when not playing
        }
        
        if self.playlist == nil {
            //initialize playlist if not already initialized
            self.playlist = Playlist(url: playlistURL!)
        }
        
        self.playlist!.getCurrent() {
            self.displayOnAir = !self.displayOnAir;
            
            if self.displayOnAir {
                //set DJ info
                self.current.isHidden = false
                self.current.text = "On Air:"
                self.currentArtist.isHidden = false
                self.currentArtist.text = self.playlist!.curShow
            } else {
                //set song info
                self.current.isHidden = false
                self.current.text   = self.playlist!.curSong
                self.currentArtist.isHidden = false
                self.currentArtist.text   = self.playlist!.curArtist
            }
        }
    }
    
    //toggle record animation
    func updateRecordState(_ playing: Bool) {
        if playing {
            startRecordAnimation()
        } else {
            stopRecordAnimation()
        }
    }
    
    func startRecordAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        let currentAngle = (record.layer.value(forKeyPath: "transform.rotation.z") as AnyObject).doubleValue ?? 0
        rotation.fromValue = NSNumber(value: currentAngle as Double)
        rotation.toValue = NSNumber(value: 2*M_PI + currentAngle as Double)
        rotation.duration = 2
        rotation.repeatCount = Float.infinity
        rotation.isRemovedOnCompletion = false
        rotation.fillMode = kCAFillModeForwards
        record.layer.add(rotation, forKey: "spin")
    }
    
    func stopRecordAnimation() {
        record.layer.transform = record.layer.presentation()!.transform
        record.layer.removeAnimation(forKey: "spin")
    }
    
    //toggle AVPlayer stream
    func updateStream(_ playing: Bool) {
        if playing {
            //create player
            self.player = AVPlayer(url: self.wborURL!)
            
            //add network observers
            self.player?.currentItem!.addObserver(self,
                forKeyPath: "playbackBufferEmpty",
                options: NSKeyValueObservingOptions.new,
                context: nil)
            self.player?.currentItem!.addObserver(self,
                forKeyPath: "playbackLikelyToKeepUp",
                options: NSKeyValueObservingOptions.new,
                context: nil)
            
            DispatchQueue(label: "Download queue", attributes: []).async(execute: {
                self.player?.play()
                return
            })
        } else {
            self.player?.pause() //pause streaming
            
            //remove network observers
            self.player?.currentItem!.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            self.player?.currentItem!.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
    }
    
    //watch for buffering events
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.player == nil {
            return
        }
        else if (object as! AVPlayerItem) == self.player!.currentItem {
            if keyPath == "playbackBufferEmpty" {
                if self.player!.currentItem!.isPlaybackBufferEmpty {
                    self.updateInfo(self.playing, buffering: true)
                    print("Buffer empty")
                }
            }
            else if keyPath == "playbackLikelyToKeepUp" {
                if self.player!.currentItem!.isPlaybackLikelyToKeepUp {
                    self.updateInfo(self.playing, buffering: false)
                    print("Buffer not empty anymore!")
                }
            }

        }
    }
    
    func DegreesToRadians(_ degrees : CGFloat) -> CGFloat {
        return degrees * CGFloat(M_PI)/CGFloat(180.0)
    }
}

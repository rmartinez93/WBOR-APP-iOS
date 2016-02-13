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
    
    var wborURL     = NSURL(string: "http://139.140.232.18:8000/WBOR")
    var playlistURL = NSURL(string: "http://wbor-hr.appspot.com/updateinfo")
    var player : AVPlayer?
    var playlist: Playlist?
    var update : NSTimer?
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioPlayerInterrupted:", name: AVAudioSessionInterruptionNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "togglePlay", name: "playButtonTapped", object: nil)
    }
    
    func rotationDetected(rotationGesture: UIRotationGestureRecognizer) {
        if rotationGesture.state == UIGestureRecognizerState.Began || rotationGesture.state == UIGestureRecognizerState.Changed {
            let rotation = rotationGesture.rotation
            let currentAngle = CGFloat((record.layer.valueForKeyPath("transform.rotation.z")?.floatValue)!)
            record.layer.setValue(currentAngle + (rotation/10), forKeyPath: "transform.rotation.z")
        }
    }
    
    var recordInterrupted: Bool = false
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.playing {
            touches.forEach { (touch) -> () in
                let touchPoint = touch.locationInView(self.view)
                let imagePoint = record.convertPoint(touchPoint, fromView: self.view)
                if self.playing && record.pointInside(imagePoint, withEvent: event) {
                    self.stopRecordAnimation()
                    self.recordInterrupted = true
                }
            }
        }
    }
    
    var lastAngle: CGFloat?
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touches.forEach { (touch) -> () in
            let touchPoint = touch.locationInView(self.view)
            let imagePoint = record.convertPoint(touchPoint, fromView: self.view)
            if record.pointInside(imagePoint, withEvent: event) {
                let angle = atan2(touchPoint.y-self.record.center.y, touchPoint.x-self.record.center.x)
                
                let position = CGFloat((record.layer.valueForKeyPath("transform.rotation.z")?.floatValue)!)
                let nextPosition = position + (angle - (lastAngle ?? angle))
                record.layer.setValue(nextPosition, forKeyPath: "transform.rotation.z")
                
                lastAngle = angle
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.playing && self.recordInterrupted {
            self.startRecordAnimation()
        }
        
        lastAngle = nil
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateInfo(self.playing, buffering: false)
        super.viewWillAppear(animated)
    }
    
    //listen for audio player interruption
    func audioPlayerInterrupted(notification : NSNotification) {
        let interruptionDictionary = notification.userInfo!
        let interruptionType = AVAudioSessionInterruptionType(rawValue: UInt(interruptionDictionary[AVAudioSessionInterruptionTypeKey]!.intValue))
        
        //audio player was interrupted
        if interruptionType == AVAudioSessionInterruptionType.Began {
            if self.playing {
                self.interrupted = true
                self.togglePlay()
            }
        }
        //audio player interruption ended
        if interruptionType == AVAudioSessionInterruptionType.Ended {
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
    func updateInfo(playing: Bool, buffering: Bool) {
        if playing {
            if self.update != nil {
                self.update!.invalidate()
            }
            current.text = "Buffering..."
            current.hidden = false
            currentArtist.hidden = true
            
            if buffering {
                return //don't load playlist info if we're struggling
            }
            
            self.displayPlaylistInfo() //update info
            
            //schedule info update
            self.update = NSTimer.scheduledTimerWithTimeInterval(5,
                target: self,
                selector: "displayPlaylistInfo",
                userInfo: nil,
                repeats: true)
        }
        else {
            if self.update != nil {
                self.update!.invalidate()
            }
            current.hidden = true
            currentArtist.hidden = true
        }
    }
    
    //update UI for song/artist info
    func displayPlaylistInfo() {
        if !self.playing {
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
                self.current.hidden = false
                self.current.text = "On Air:"
                self.currentArtist.hidden = false
                self.currentArtist.text = self.playlist!.curShow
            } else {
                //set song info
                self.current.hidden = false
                self.current.text   = self.playlist!.curSong
                self.currentArtist.hidden = false
                self.currentArtist.text   = self.playlist!.curArtist
            }
        }
    }
    
    //toggle record animation
    func updateRecordState(playing: Bool) {
        if playing {
            startRecordAnimation()
        } else {
            stopRecordAnimation()
        }
    }
    
    func startRecordAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        let currentAngle = record.layer.valueForKeyPath("transform.rotation.z")?.doubleValue
        rotation.fromValue = NSNumber(double: currentAngle!)
        rotation.toValue = NSNumber(double: 2*M_PI + currentAngle!)
        rotation.duration = 2
        rotation.repeatCount = Float.infinity
        rotation.removedOnCompletion = false
        rotation.fillMode = kCAFillModeForwards
        record.layer.addAnimation(rotation, forKey: "spin")
    }
    
    func stopRecordAnimation() {
        record.layer.transform = record.layer.presentationLayer()!.transform
        record.layer.removeAnimationForKey("spin")
    }
    
    //toggle AVPlayer stream
    func updateStream(playing: Bool) {
        if playing {
            //create player
            self.player = AVPlayer(URL: self.wborURL!)
            
            //add network observers
            self.player?.currentItem!.addObserver(self,
                forKeyPath: "playbackBufferEmpty",
                options: NSKeyValueObservingOptions.New,
                context: nil)
            self.player?.currentItem!.addObserver(self,
                forKeyPath: "playbackLikelyToKeepUp",
                options: NSKeyValueObservingOptions.New,
                context: nil)
            
            dispatch_async(dispatch_queue_create("Download queue", nil), {
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
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if self.player == nil {
            return
        }
        else if (object as! AVPlayerItem) == self.player!.currentItem {
            if keyPath == "playbackBufferEmpty" {
                if self.player!.currentItem!.playbackBufferEmpty {
                    self.updateInfo(self.playing, buffering: true)
                    print("Buffer empty")
                }
            }
            else if keyPath == "playbackLikelyToKeepUp" {
                if self.player!.currentItem!.playbackLikelyToKeepUp {
                    self.updateInfo(self.playing, buffering: false)
                    print("Buffer not empty anymore!")
                }
            }

        }
    }
    
    func DegreesToRadians(degrees : CGFloat) -> CGFloat {
        return degrees * CGFloat(M_PI)/CGFloat(180.0)
    }
}
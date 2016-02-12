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

class RootViewController : UIViewController {
    @IBOutlet var current : UILabel!
    @IBOutlet var currentArtist : UILabel!
    @IBOutlet var record : UIImageView!
    
    var wborURL     = NSURL(string: "http://139.140.232.18:8000/WBOR")
    var playlistURL = NSURL(string: "http://wbor-hr.appspot.com/updateinfo")
    var player : AVPlayer?
    var update : NSTimer?
    var displayCounter = 0
    var playing : Bool = false
    
    override func viewDidLoad() {
        current.hidden = true
        currentArtist.hidden = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "togglePlay", name: "playButtonTapped", object: nil)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateInfo(self.playing, buffering: false)
        super.viewWillAppear(animated)
    }
    
    func togglePlay() {
        self.playing = !self.playing //toggle playing
        
        //update player state
        self.updateRecordState(self.playing)
        self.updateInfo(self.playing, buffering: self.playing)
        self.updateStream(self.playing)
    }
    
    func displayPlaylistInfo() {
        //initialize playlist
        let playList = Playlist(url: playlistURL!)
        playList.getCurrent()
        
        displayCounter++;
        
        if displayCounter%2 == 0 {
            //set DJ info
            current.hidden = false
            current.text = "On Air:"
            currentArtist.hidden = false
            currentArtist.text = playList.curShow
        } else {
            //set song info
            current.hidden = false
            current.text   = playList.curSong
            currentArtist.hidden = false
            currentArtist.text   = playList.curArtist
        }
    }
    
    func updateInfo(playing: Bool, buffering: Bool) {
        if buffering {
            if self.update != nil {
                self.update?.invalidate()
            }
            current.hidden = false
            current.text = "Buffering..."
            currentArtist.hidden = true
        } else {
            if playing {
                self.displayPlaylistInfo() //update info
                
                //schedule info update
                self.update = NSTimer.scheduledTimerWithTimeInterval(5,
                    target: self,
                    selector: "displayPlaylistInfo",
                    userInfo: nil,
                    repeats: true)
            }
            else {
                current.hidden = true
                currentArtist.hidden = true
                self.update?.invalidate()
            }
        }
    }
    
    func updateRecordState(playing: Bool) {
        if playing {
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            let currentAngle = record.layer.valueForKeyPath("transform.rotation.z")?.doubleValue
            rotation.fromValue = NSNumber(double: currentAngle!)
            rotation.toValue = NSNumber(double: 2*M_PI + currentAngle!)
            rotation.duration = 2
            rotation.repeatCount = Float.infinity
            rotation.removedOnCompletion = false
            rotation.fillMode = kCAFillModeForwards
            record.layer.addAnimation(rotation, forKey: "spin")
        } else {
            record.layer.transform = record.layer.presentationLayer()!.transform
            record.layer.removeAnimationForKey("spin")
        }
    }
    
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
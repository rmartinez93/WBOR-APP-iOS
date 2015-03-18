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
    @IBOutlet var play : UIButton!
    @IBOutlet var stop : UIButton!
    @IBOutlet var current : UILabel!
    @IBOutlet var currentArtist : UILabel!
    @IBOutlet var record : UIImageView!
    @IBOutlet var toolbar : UIToolbar!
    @IBOutlet var volumeControl : MPVolumeView!
    
    var wborURL     = NSURL(string: "http://139.140.232.18:8000/WBOR")
    var playlistURL = NSURL(string: "http://wbor-hr.appspot.com/updateinfo")
    var player : AVPlayer?
    var update : NSTimer?
    var displayCounter = 0
    
    override func viewDidLoad() {
        current.hidden = true
        currentArtist.hidden = true
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.showMoreInfo(false)
        super.viewWillAppear(animated)
    }
    
    @IBAction func togglePlay(sender : UIButton) {
        if sender.tag == 0 {
            //Set Loading...
            play.enabled   = false
            sender.enabled = false    //Disable Play Button
            stop.enabled   = true     //Enable Stop Button
            self.setPlayingButtons()  //Set Play Button as Active
            self.recordRotation(true) //Start Rotation
            self.showMoreInfo(true)   //Update Info to Buffering
            
            //Begin Stream
            self.startStream()
        } else if sender.tag == 1 {
            sender.enabled = false     //Disable Stop Button
            play.enabled   = true      //Enable Play Button
            self.setPausedButtons()    //Set Pause Button as Active
            self.recordRotation(false) //Stop Rotation
            self.showMoreInfo(false)   //End Info Updating
            
            //Stop Stream
            self.stopStream()
        }
    }
    
    func displayPlaylistInfo() {
        //initialize playlist
        var playList = Playlist(url: playlistURL!)
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
    
    func showMoreInfo(buffering: Bool) {
        if buffering {
            if self.update != nil {
                self.update?.invalidate()
            }
            current.hidden = false
            current.text = "Buffering..."
            currentArtist.hidden = true
        } else {
            if !play.enabled {
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
    
    func setPlayingButtons() {
        play.setBackgroundImage(UIImage(named: "play2.png"), forState: UIControlState.Normal)
        stop.setBackgroundImage(UIImage(named: "pause.png"), forState: UIControlState.Normal)
    }
    
    func setPausedButtons() {
        play.setBackgroundImage(UIImage(named: "play.png"), forState: UIControlState.Normal)
        stop.setBackgroundImage(UIImage(named: "pause2.png"), forState: UIControlState.Normal)
    }
    
    func recordRotation(start: Bool) {
        if start {
            var rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.toValue = NSNumber(double: 2*M_PI)
            rotation.duration = 1
            rotation.cumulative = true
            rotation.repeatCount = Float.infinity
            rotation.removedOnCompletion = false
            rotation.fillMode = kCAFillModeForwards
            record.layer.addAnimation(rotation, forKey: "spin")
        } else {
            record.layer.removeAnimationForKey("spin")
        }
    }
    
    func startStream() {
        //create player
        self.player = AVPlayer(URL: self.wborURL)
        
        //add network observers
        self.player?.currentItem.addObserver(self,
                                        forKeyPath: "playbackBufferEmpty",
                                           options: NSKeyValueObservingOptions.New,
                                           context: nil)
        self.player?.currentItem.addObserver(self,
                                        forKeyPath: "playbackLikelyToKeepUp",
                                           options: NSKeyValueObservingOptions.New,
                                           context: nil)
        
        dispatch_async(dispatch_queue_create("Download queue", nil), {
            self.player?.play()
            return
        })
    }
    
    func stopStream() {
        self.player?.pause() //pause streaming
        
        //remove network observers
        self.player?.currentItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.player?.currentItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if self.player == nil {
            return
        }
        else if (object as AVPlayerItem) == self.player!.currentItem {
            if keyPath == "playbackBufferEmpty" {
                if self.player!.currentItem.playbackBufferEmpty {
                    self.showMoreInfo(true)
                    NSLog("Bugger empty")
                }
            }
            else if keyPath == "playbackLikelyToKeepUp" {
                if self.player!.currentItem.playbackLikelyToKeepUp {
                    self.showMoreInfo(false)
                }
            }

        }
    }
    
    func DegreesToRadians(degrees : CGFloat) -> CGFloat {
        return degrees * CGFloat(M_PI)/CGFloat(180.0)
    }
}
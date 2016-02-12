//
//  PlayerControlsView.swift
//  WBOR
//
//  Created by Ruben on 2/11/16.
//
//
import UIKit

class PlayerControlsView: UIView {
    @IBOutlet weak var playButton: UIButton!
    var playing: Bool = false

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
    }
    
    @IBAction func playButtonTapped() {
        updateButton()
        NSNotificationCenter.defaultCenter().postNotificationName("playButtonTapped", object: nil)
    }
    
    func updateButton() {
        self.playing = !self.playing //toggle play state
        
        if self.playing {
            playButton.setBackgroundImage(UIImage(named: "pause.png"), forState: UIControlState.Normal)
        } else {
            playButton.setBackgroundImage(UIImage(named: "play.png"), forState: UIControlState.Normal)
        }
    }
}
//
//  FirstViewController.h
//  WBOR FINAL
//
//  Created by Connor Smith on 12/16/11.
//  Modified by Ruben Martinez on 02/09/2014
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PlayList.h"

@class StreamModel;
@interface FirstViewController : UIViewController {
    IBOutlet UIButton *play;
    IBOutlet UIButton *stop;
    IBOutlet UIImageView *record;
    AVPlayer *player;
    NSString *m3uPath;
    NSURL *wbor;
    NSTimer *update;
    IBOutlet UILabel *current;
    IBOutlet UILabel *currentArtist;
    IBOutlet UIToolbar *toolbar;
}

@property (weak, nonatomic) IBOutlet MPVolumeView *volumeControl;
@property (retain, nonatomic) AVPlayer *player;
@property (retain) NSString *m3uPath;
@property (retain) NSURL *wbor;
@property (retain) NSTimer *update;

- (IBAction)togglePlay:(UIButton *)sender;
- (void)updateSongInfo;
- (void)setPlayingButtons;
- (void)setPausedButtons;
@end

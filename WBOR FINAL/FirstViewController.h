//
//  FirstViewController.h
//  WBOR FINAL
//
//  Created by Connor Smith on 12/16/11.
//  Modified by Ruben Martinez on 02/09/2014
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "PlayList.h"

@interface FirstViewController : UIViewController {
    IBOutlet UIButton *play;
    IBOutlet UIButton *stop;
    IBOutlet UIImageView *record;
    StreamModel *streamer;
    NSString *m3uPath;
    NSURL *wbor;
    NSTimer *update;
    IBOutlet UILabel *current;
    IBOutlet UILabel *currentArtist;
    IBOutlet UIToolbar *toolbar;
    
}



@property (retain, nonatomic) StreamModel *streamer;
@property (retain) NSString *m3uPath;
@property (retain) NSURL *wbor;
@property (retain) NSTimer *update;

- (void)slowRecord:(UITapGestureRecognizer *)sender;
- (IBAction)togglePlay:(UIButton *)sender;
- (void)updateSongInfo;
@end

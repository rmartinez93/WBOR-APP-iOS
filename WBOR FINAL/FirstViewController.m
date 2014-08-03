//
//  FirstViewController.m
//  WBOR FINAL
//
//  Created by Connor Smith on 12/16/11.
//  Modified by Ruben Martinez on 02/09/14
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import <QuartzCore/CoreAnimation.h>

@implementation FirstViewController

@synthesize wbor, m3uPath, update, player;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [current setHidden:TRUE];
    [currentArtist setHidden:TRUE];
    self.m3uPath = @"http://139.140.232.18:8000/WBOR";
    self.wbor = [[NSURL alloc] initWithString:m3uPath];
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];

    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)updateSongInfo {
    if(![play isEnabled]) {
        PlayList *playList = [[PlayList alloc] init];
        [playList getCurrent];
        [current setHidden:FALSE];
        [current setText:playList.curSong];
        [currentArtist setHidden:FALSE];
        [currentArtist setText:playList.curArtist];
    }
    else {
        [current setHidden:TRUE];
        [currentArtist setHidden:TRUE];
        [self.update invalidate];
    }
}

-(void)showMoreInfo:(BOOL)buffering {
    if(buffering) {
        if(self.update) [self.update invalidate];
        [current setText:@"Buffering..."];
        [currentArtist setHidden:TRUE];
    } else {
        if(![play isEnabled]) {
            PlayList *playList = [[PlayList alloc] init];
            [playList getCurrent];
            [current setHidden:FALSE];
            [current setText:@"On Air:"];
            [currentArtist setHidden:FALSE];
            [currentArtist setText:playList.curShow];
            self.update = [NSTimer scheduledTimerWithTimeInterval:10
                                                           target:self
                                                         selector:@selector(updateSongInfo)
                                                         userInfo:nil
                                                          repeats:NO];
        }
        else {
            [current setHidden:TRUE];
            [currentArtist setHidden:TRUE];
            [self.update invalidate];
        }
    }
}

-(void)setPlayingButtons {
    [play setBackgroundImage:[UIImage imageNamed:@"play2.png"]
                             forState:UIControlStateNormal];
    [stop setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                             forState:UIControlStateNormal];
}

-(void)setPausedButtons {
    [play setBackgroundImage:[UIImage imageNamed:@"play.png"]
                    forState:UIControlStateNormal];
    [stop setBackgroundImage:[UIImage imageNamed:@"pause2.png"]
                    forState:UIControlStateNormal];
}

-(void)recordRotation:(BOOL)start {
    if(start) {
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
        rotation.duration = 1;
        rotation.cumulative = YES;
        rotation.repeatCount = HUGE_VALF;
        rotation.removedOnCompletion = NO;
        rotation.fillMode = kCAFillModeForwards;
        [record.layer addAnimation:rotation forKey:@"spin"];
    }
    else {
        [record.layer removeAnimationForKey:@"spin"];
    }
}

-(void)startStream {
    //create player
    self.player = [AVPlayer playerWithURL:self.wbor];
    
    //add network observers
    [self.player.currentItem addObserver:self
                              forKeyPath:@"playbackBufferEmpty"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"playbackLikelyToKeepUp"
                                 options:NSKeyValueObservingOptionNew context:nil];
    
    //spawn new thread
    dispatch_async(dispatch_queue_create("Download queue", nil), ^(void) {
        [self.player play]; //start streaming
    });
}
-(void)stopStream {
    [self.player pause]; //pause streaming
    
    //remove old network observers
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];

    [self showMoreInfo:false]; //request playlist info
}

- (IBAction)togglePlay:(UIButton *)sender{
    if (sender.tag == 0){
        //Set Loading...
        [play setEnabled: NO];
        [sender setEnabled:false]; //Disable Play Button
        [stop setEnabled:true];    //Enable Stop Button
        [self setPlayingButtons];  //Set Play Button as Active
        [self recordRotation:YES]; //Start Rotation
        [current setHidden:FALSE];
        [self showMoreInfo:true];
        
        [self startStream];
    }
    else if (sender.tag == 1){
        [sender setEnabled:false]; //Disable Stop Button
        [play setEnabled: YES];    //Enable Play Button
        [self setPausedButtons];   //Set Pause Button as Active
        [self updateSongInfo];     //Kill Info Updating
        [self recordRotation:NO];  //Stop Rotation
        [self stopStream];         //Stop Stream
    }
    
}

//handle special cases
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (!self.player) return;
    else if (object == self.player.currentItem && [keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (self.player.currentItem.playbackBufferEmpty) {
            [self showMoreInfo:true];
            NSLog(@"EMPTY");
        }
    }
    else if (object == self.player.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        if (self.player.currentItem.playbackLikelyToKeepUp) {
            [self showMoreInfo:false];
            NSLog(@"ALL GOOOD");
        }
    }
}

-(CGFloat) DegreesToRadians:(CGFloat)degrees {
    return degrees * M_PI /180;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showMoreInfo:false];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}
 
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end

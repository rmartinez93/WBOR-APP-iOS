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

@synthesize streamer, wbor, m3uPath, update;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [current setHidden:TRUE];
    [currentArtist setHidden:TRUE];
	self.streamer = [[StreamModel alloc] init];
    self.m3uPath = @"http://139.140.232.18:8000/WBOR";
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
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showMoreInfo) userInfo:nil repeats:NO];
    }
    else {
        [current setHidden:TRUE];
        [currentArtist setHidden:TRUE];
        [self.update invalidate];
    }
}

-(void)showMoreInfo {
    if(![play isEnabled]) {
        PlayList *playList = [[PlayList alloc] init];
        [playList getCurrent];
        [current setHidden:FALSE];
        [current setText:@"On Air:"];
        [currentArtist setHidden:FALSE];
        [currentArtist setText:playList.curShow];
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateSongInfo) userInfo:nil repeats:NO];
    }
    else {
        [current setHidden:TRUE];
        [currentArtist setHidden:TRUE];
        [self.update invalidate];
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
    self.wbor = [[NSURL alloc] initWithString:m3uPath];
    self.streamer = [[StreamModel alloc] initWithURL:wbor];
    [self.streamer start:self];          //Start Streaming
}
-(void)stopStream {
    [self.streamer stop];           //Stop Streaming
}

- (IBAction)togglePlay:(UIButton *)sender{
    if (sender.tag == 0){
        [play setEnabled: NO];          //Disable Play Button
        [self setPlayingButtons];       //Set Play Button as Active
        [self recordRotation:YES];      //Start Rotation
        
        //Set Loading...
        [current setHidden:FALSE];
        [current setText:@"Buffering..."];
        
        //Wait, then start stream
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(startStream) userInfo:nil repeats:NO];
    }
    else if (sender.tag == 1){
        [play setEnabled: YES];         //Enable Play Button
        [self setPausedButtons];        //Set Pause Button as Active
        [self updateSongInfo];          //Kill Info Updating
        [self recordRotation:NO];    //Stop Rotation
        [self stopStream];              //Stop Stream
        self.streamer = nil;            //Invalidate Streamer
    }
    
}

-(CGFloat) DegreesToRadians:(CGFloat)degrees {
    return degrees * M_PI /180;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

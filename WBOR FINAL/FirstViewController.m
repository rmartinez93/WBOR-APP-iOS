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

@synthesize streamer, wbor, m3uPath;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
}

- (IBAction)togglePlay:(UIButton *)sender{
    if (sender.tag == 0){
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
        rotation.duration = 1;
        rotation.cumulative = YES;
        rotation.repeatCount = HUGE_VALF;
        rotation.removedOnCompletion = NO;
        [record.layer addAnimation:rotation forKey:@"spin"];
        
        self.update = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateSongInfo) userInfo:Nil repeats:YES];
        [play setBackgroundImage:[UIImage imageNamed:@"play2.png"]
                       forState:UIControlStateNormal];
        [stop setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                        forState:UIControlStateNormal];
        [play setEnabled: NO];
        [self updateSongInfo];
        self.wbor = [[NSURL alloc] initWithString:m3uPath];
        self.streamer = [[StreamModel alloc] initWithURL:wbor];
        [self.streamer start];
        
    }
    else if (sender.tag == 1){
        [self.update invalidate];
        //record.layer.transform = [(CALayer *)[record.layer presentationLayer] transform];
        [record.layer removeAnimationForKey:@"spin"];
        [current setHidden:TRUE];
        [currentArtist setHidden:TRUE];
        [play setBackgroundImage:[UIImage imageNamed:@"play.png"]
                        forState:UIControlStateNormal];
        [stop setBackgroundImage:[UIImage imageNamed:@"pause2.png"]
                        forState:UIControlStateNormal];
        [self.streamer stop];
        self.streamer = nil;
        [play setEnabled: YES];
        
    }
    
}

- (void)updateVolume {
    
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
    /*
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return NO;
    }
     */
}

@end

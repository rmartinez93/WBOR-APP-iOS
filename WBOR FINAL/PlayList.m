//
//  PlayList.m
//  WBOR FINAL
//
//  Created by Connor Smith on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayList.h"

@implementation PlayList

@synthesize curSong, curArtist;

- (void)getCurrent{
    WBOR = [NSURL URLWithString:@"http://wbor-hr.appspot.com/updateinfo"];    
    NSData* data = [NSData dataWithContentsOfURL: 
                        WBOR];

    
    [self handleData:data];
}

- (void)handleData:(NSData *)responseData {
    //parse out the json data into a dictionary because it pretty much already is a dictionary
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData 
                          
                          options:kNilOptions 
                          error:&error];
    
    NSString *song, *artist, *show;
    song    = [json objectForKey:@"song_string"];
    artist  = [json objectForKey:@"artist_string"];
    show    =[json objectForKey:@"program_title"];

    self.curShow = show;
    self.curSong = song;
    self.curArtist = artist;
}

@end

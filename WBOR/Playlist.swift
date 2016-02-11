//
//  Playlist.swift
//  WBOR
//
//  Created by Ruben Martinez Jr on 8/2/14.
//
//

import Foundation

class Playlist : NSObject {
    var wborInfo  : NSURL
    var curSong   : String?
    var curArtist : String?
    var curShow   : String?
    
    init(url: NSURL) {
        self.wborInfo = url
        super.init()
    }
    
    func getCurrent() {
        let data  = NSData(contentsOfURL: self.wborInfo)
        
        do {
            let json  = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: String]

            if let info = json {
                self.curSong    = info["song_string"]!
                self.curArtist  = info["artist_string"]!
                self.curShow    = info["program_title"]!
            }
        } catch _ {
            print("Bad JSON Data received: See Playlist Class.");
        }
        
    }
}
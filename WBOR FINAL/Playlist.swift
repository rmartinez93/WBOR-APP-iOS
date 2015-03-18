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
        var data  = NSData(contentsOfURL: self.wborInfo)
        var error : NSError?
        var json  = NSJSONSerialization.JSONObjectWithData(data!,
                                                           options: nil,
                                                           error: &error) as Dictionary<String, String>

        self.curSong    = json["song_string"]!
        self.curArtist  = json["artist_string"]!
        self.curShow    = json["program_title"]!
        
    }
}
//
//  Playlist.swift
//  WBOR
//
//  Created by Ruben Martinez Jr on 8/2/14.
//
//

import Foundation

class Playlist : NSObject {
    var wborInfo  : URL
    var curSong   : String?
    var curArtist : String?
    var curShow   : String?
    var lastData  : Data?
    
    init(url: URL) {
        self.wborInfo = url
        super.init()
    }
    
    func getCurrent(_ callback: @escaping () -> ()) {
        DispatchQueue.global().async {
            let playlistData  = try? Data(contentsOf: self.wborInfo)
            
            if let data = playlistData ?? self.lastData {
                DispatchQueue.main.async {
                    do {
                        let json  = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                        
                        if let info = json {
                            self.curSong    = info["song_string"]!
                            self.curArtist  = info["artist_string"]!
                            self.curShow    = info["program_title"]!
                        }
                        
                        self.lastData = data
                        
                        callback()
                    }  catch _ {
                        print("Bad JSON Data received: See Playlist Class.");
                    }
                }
            }
        }
    }
}

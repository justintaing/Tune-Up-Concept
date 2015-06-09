//
//  TuneUpConcept2.swift
//  TuneUpConcept2
//
//  Created by Justin Taing on 1/7/15.
//  Copyright (c) 2015 Justin Taing. All rights reserved.
//

import Foundation
import CoreData

class SongItem: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var artist: String
    @NSManaged var album: String
    @NSManaged var plays: Int
    @NSManaged var skips: Int
    @NSManaged var playRate: Double

    class func createSongInManagedObjectContext(moc: NSManagedObjectContext,
        title: String, artist: String, album: String,
        plays: Int, skips: Int) -> SongItem {
        
        let newSong = NSEntityDescription.insertNewObjectForEntityForName("SongItem", inManagedObjectContext: moc) as SongItem
        newSong.title = title
        newSong.artist = artist
        newSong.album = album
        newSong.plays = plays
        newSong.skips = skips
        newSong.playRate = newSong.songHasBeenHeard() ? newSong.calculatePlayRate() : 0.0
            
        return newSong
    }
    
    private func songHasBeenHeard() -> Bool {
        if ((self.plays + self.skips) > 0) { return true }
        else { return false }
    }
    
    private func calculatePlayRate() -> Double {
        let multiplier = 100.0
        let plays = self.plays
        let skips = self.skips
        
        if (plays == 0) { return 0.0 }
        
        var rate = round((Double(plays) / Double(plays + skips)) * multiplier) / multiplier
        
        return rate
    }
}
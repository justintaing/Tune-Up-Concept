//
//  PlaysViewController.swift
//  TuneUpConcept2
//
//  Created by Justin Taing on 1/7/15.
//  Copyright (c) 2015 Justin Taing. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

class PlaysViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var playTableView = UITableView(frame: CGRectZero, style: .Plain)
    var playedSongs = [SongItem]()
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = false
        
        var viewFrame = self.view.frame
        viewFrame.origin.y += 20
        viewFrame.size.height -= 70
        playTableView.frame = viewFrame
        
        self.view.addSubview(playTableView)
        
        playTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SongItem")
        playTableView.dataSource = self
        playTableView.delegate = self
        
        //fetch BEFORE getting
        fetchSongs()
        if (playedSongs.count == 0) {
            getSongs()
            fetchSongs()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
    
    }
    
    func getSongs() {
        var filterCloudPredicate = MPMediaPropertyPredicate(value: NSNumber(bool: false), forProperty: MPMediaItemPropertyIsCloudItem)
        var songResults = MPMediaQuery.songsQuery()
        songResults.addFilterPredicate(filterCloudPredicate)
        for song in songResults.items {
            SongItem.createSongInManagedObjectContext(managedObjectContext!, title: song.valueForProperty(MPMediaItemPropertyTitle) as String, artist: song.valueForProperty(MPMediaItemPropertyArtist) as String, album: song.valueForProperty(MPMediaItemPropertyAlbumTitle) as String, plays: song.valueForProperty(MPMediaItemPropertyPlayCount) as Int, skips: song.valueForProperty(MPMediaItemPropertySkipCount) as Int)
        }
        save()
    }
    
    func fetchSongs() {
        let fetchRequest = NSFetchRequest(entityName: "SongItem")
        
        let playRateDescriptor = NSSortDescriptor(key: "plays", ascending: false)
        let titleDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        fetchRequest.sortDescriptors = [playRateDescriptor, titleDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [SongItem] {
            for song in fetchResults {
                if (song.plays > 0) {
                    playedSongs += [song]
                }
            }
        }
    }
    
    func save() {
        var error: NSError?
        if (managedObjectContext!.save(&error)) {
            println(error?.localizedDescription)
        }
    }
    
    func purgeMoc() {

    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playedSongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongItem") as UITableViewCell
        let songItem = playedSongs[indexPath.row]
        cell.textLabel?.text = NSString(format: "%d | %@", songItem.plays, songItem.title)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let songItem = playedSongs[indexPath.row]
        
        var alert = UIAlertController(title: songItem.title, message: NSString(format: "Plays: %d | Skips: %d | Rate: %.2f", songItem.plays, songItem.skips, songItem.playRate), preferredStyle: .Alert)
        
        var close = UIAlertAction(title: "Close", style: .Default, handler: nil)
        
        alert.addAction(close)
        
        self.presentViewController(alert, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

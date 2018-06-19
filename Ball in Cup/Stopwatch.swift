//
//  Stopwatch.swift
//  Ball in Cup
//
//  Created by Jason Simon on 7/22/16.
//  Copyright © 2016 Jason Simon. All rights reserved.
//

import Foundation

/** This class represents a stopwatch for a game interface, which formats
  * differently depending on how much time has passed. */
class Stopwatch {

    var timePassed : Int // time, in one-tenth seconds
    
    init (time: Int) {
        timePassed = time
    }

    // formats time into ":" style
    func timeStamp () -> String {
        var stamp : String = ""
        var currTimePassed = timePassed
        let hours : Int = currTimePassed / 36000
        currTimePassed %= 36000
        let minutes : Int = currTimePassed / 600
        currTimePassed %= 600
        let seconds : Int = currTimePassed / 10
        currTimePassed %= 10
        let tenthSeconds : Int = currTimePassed
        stamp = String(seconds) + "." + String(tenthSeconds)
        
        if hours != 0 {
            stamp = timeToString(hours) + ":" + timeToString(minutes)
                + ":" + timeToString(seconds)
        } else if minutes != 0 {
            stamp = timeToString(minutes) + ":" + timeToString(seconds)
        }
        
        if timePassed < 0 {
            return "0.0"
        }
        
        return stamp
        
    }
    
    func incTime () {
        timePassed += 1
    }
    
    func decTime () {
        timePassed -= 1
    }
    
    func getTimePassed() -> Int {
        return timePassed
    }
    
    // helper function to add leading zeros when necessary for aesthetics
    fileprivate func timeToString (_ time : Int) -> String {
        
        var timeString : String
        
        if (time < 10) {
            timeString = "0" + String(time)
        } else {
            timeString = String(time)
        }
        
        return timeString
    }
}

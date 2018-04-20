//
//  DateUtil.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 20/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

let hour = 60 * 60
let hours_24 = hour * 24
let days_2 = hour * 48

class DateUtil {
    static func getRelativeTimeString(since sinceMillisecond: Double, until untilMillisecond: Double = Double(Date().timeIntervalSince1970)) -> String {
        let sinceDate = Date(timeIntervalSince1970: sinceMillisecond/1000.0)
        let untilDate = Date(timeIntervalSince1970: untilMillisecond/1000.0)
        let diff = (Int((untilDate.timeIntervalSince1970).rounded()) - Int((sinceDate.timeIntervalSince1970).rounded()))
        
        if diff < 0 {
            return "since cannot be greater than until"
        }
        
        if diff < hour {
            return "\(diff/60) minutes ago"
        }else if diff < hours_24 {
            return "\(diff/60/60) hours ago"
        }else if diff < days_2 {
            return "\(diff/60/60/24) days ago"
        }else {
            let (dateString,timeString) = getDateTimeString(of: sinceMillisecond)
            return "\(dateString) \(timeString)"
        }
    }
    
    static func getDateTimeString(of millisecond: Double) -> (String, String) {
        let date = Date(timeIntervalSince1970: millisecond/1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H:mm"
        return (formatter.string(from: date), timeFormatter.string(from: date))
    }
}

//
//  DateUtil.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 20/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

let minute = 60.0
let hour = minute * 60.0
let hours_24 = hour * 24.0
let days_2 = hour * 48.0

class DateUtil {
    
    static private func isPlural(n: Double) -> Bool {
        return n != 1.0
    }
    
    static func getRelativeTimeString(since sinceMillisecond: Double, until untilMillisecond: Double = Double(Date().timeIntervalSince1970*1000)) -> String {
        let sinceDate = Date(timeIntervalSince1970: sinceMillisecond/1000.0)
        let untilDate = Date(timeIntervalSince1970: untilMillisecond/1000.0)
        let diff = (Double((untilDate.timeIntervalSince1970).rounded()) - Double((sinceDate.timeIntervalSince1970).rounded()))
        
        if diff < 0 {
            return "since cannot be greater than until"
        }
        
        let (dateString,timeString) = getDateTimeString(of: sinceMillisecond)
        
        if diff < hour {
            let n = ceil(diff/60.0)
            return "\(Int(n)) minute\(isPlural(n: n) ? "s" : "") ago (\(dateString) \(timeString))"
        } else if diff < hours_24 {
            let n = ceil(diff/hour)
            return "\(Int(n)) hour\(isPlural(n: n) ? "s" : "") ago (\(dateString) \(timeString))"
        } else if diff < days_2 {
            let n = ceil(diff/hours_24)
            return "\(Int(n)) day\(isPlural(n: n) ? "s" : "") ago (\(dateString) \(timeString))"
        } else {
            return "\(dateString) \(timeString)"
        }
    }
    
    static func getDateTimeString(of millisecond: Double) -> (String, String) {
        let date = Date(timeIntervalSince1970: millisecond/1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H:mm"
        return (formatter.string(from: date), timeFormatter.string(from: date))
    }
}

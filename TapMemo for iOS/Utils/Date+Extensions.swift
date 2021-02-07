//
//  Extensions.swift
//  TapMemo for iOS
//
//  Created by 一折 on 2021/2/6.
//

import UIKit

extension Date {
    func toString() -> String{
        let dateFormatter = DateFormatter()
        if Date.is24Hour() {
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss a"
        }
        let string = dateFormatter.string(from: self)
        return string
    }
    
    static func is24Hour() -> Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return dateFormat.firstIndex(of: "a") == nil
    }
    
    static func now() -> Date {
        return Date(timeIntervalSinceNow: 0)
    }
    
    static func random() -> Date {
        guard let interval = self.intervals.randomElement() else { return self.now()}
        return Date(timeIntervalSinceNow: Double(interval))
    }
    
    static func isRecentWeek(dateString: String) -> Bool {
        let weekAgo = Date.now().advanced(by: -7*24*60*60).toString()
        return dateString > weekAgo
    }
    
    private static let intervals = [-70000, 0, -3213213, -21390213, -432432, -4234, -643643]
}

//
//  RE.swift
//  Touch Memo
//
//  Created by 一折 on 2021/1/17.
//

import UIKit

struct Parsed {
    var content: String
    var range: NSRange
}

class RE: NSObject {
    static func regularExpression(validateString:String, inRegex regex:String) -> [String]{
        do {
            let re: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = re.matches(in: validateString, options:[], range: NSRange(location: 0, length: validateString.count))
            
            var data:[String] = Array()
            for item in matches {
                let string = (validateString as NSString).substring(with: item.range)
                data.append(string)
            }
            
            return data
        }
        catch {
            return []
        }
    }
    
    static func regularExpressionRange(validateString:String, inRegex regex:String) -> [Parsed]{
        do {
            let re: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = re.matches(in: validateString, options:[], range: NSRange(location: 0, length: validateString.count))
            
            var data:[Parsed] = Array()
            for item in matches {
                let string = (validateString as NSString).substring(with: item.range)
                data.append(Parsed(content: string, range: item.range))
            }
            
            return data
        }
        catch {
            return []
        }
    }
    
    static func replace(validateString: String, withContent content: String, inRegex regex:String) -> String {
        do {
            let re: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            return re.stringByReplacingMatches(in: validateString, options: [], range: NSRange(location: 0, length: validateString.count), withTemplate: content)
        } catch {
            return validateString
        }
    }
}

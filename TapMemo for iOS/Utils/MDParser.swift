//
//  MDParser.swift
//  Touch Memo
//
//  Created by 一折 on 2021/1/16.
//

import UIKit

struct Replaced {
    let string: String
    let range: Range<String.Index>
}

class MDParser: NSObject {
    
    static let headerRegex = "^#{1,3}"
    static let orderRegex = "^[0-9]+\\."
    static let bulletRegex = "^-"
    static let orderListBlockRegex = "(?<=(^|\n))([0-9]+\\..*(\n)?)*(?<=(^|\n))([0-9]+\\..*)+"
    static let bulletBlocksRegex = "(?<=(^|\n))-.*(\n)?"
    static let headerBlocksRegex = "(?<=(^|\n))#{1,3}.*(\n)?"
    static let specielRegex = "(?<=(^|\n))(#{1,3}|[0-9]+\\.|-)"
    
    static func getTitle(content: String) -> String {
        guard let title = RE.regularExpression(validateString: content, inRegex: "^#{1,3}.*\n?").first else {return ""}
        return RE.replace(validateString: title, withContent: "", inRegex: "^#{1,3} +")
    }
    
    static func renderAll(content: String) -> NSAttributedString {
        let result = NSMutableAttributedString(string: content, attributes: self.normalAttribute())
        // render header
        let headers = RE.regularExpressionRange(validateString: content, inRegex: self.headerBlocksRegex)
        for parsed in headers {
            let level = self.getHeaderLevel(header: parsed.content)
            let attributes = self.headerAttribute(level: level)
            result.addAttributes(attributes, range: parsed.range)
        }
        // render ordered list
        let orderedList = RE.regularExpressionRange(validateString: content, inRegex: self.orderListBlockRegex)
        for parsed in orderedList {
            let replaced = RE.replace(validateString: parsed.content, withContent: "", inRegex: "(?<=(^|\n))[0-9]+")
            var splited = replaced.split(separator: "\n")
            splited = splited.enumerated().map({(i, line) in "\(i+1)"+line})
            let s = splited.joined(separator: "\n")
            result.mutableString.replaceCharacters(in: parsed.range, with: s)
            result.addAttributes(self.listAttribute(), range: parsed.range)
        }
        // render bullet list
        let bulletList = RE.regularExpressionRange(validateString: content, inRegex: self.bulletBlocksRegex)
        for parsed in bulletList {
            result.addAttributes(self.listAttribute(), range: parsed.range)
        }
        //highlight special signs
        for parsed in RE.regularExpressionRange(validateString: content, inRegex: self.specielRegex) {
            result.addAttributes([
                .foregroundColor: UIColor(named: "AccentColor")!
            ], range: parsed.range)
        }
        
        return result
    }
    
    // MARK: - Update Attributes
    
    static func updateHeader(s: String) -> String {
        if s == "\n" {return s+"# "}
        let re = RE.regularExpression(validateString: s, inRegex: self.headerRegex)
        if re.count == 0 {
            return "# " + s
        }
        let level = re[0].count
        var replaced = String(repeating: "#", count: (level + 1) % 4)
        if replaced.count > 0 {
            replaced += " "
        }
        return RE.replace(validateString: s, withContent: replaced, inRegex: self.headerRegex+"[ ]*")
    }
    
    static func updateOrder(s: String) -> String {
        if s == "\n" {return s+"1. "}
        let order = RE.regularExpression(validateString: s, inRegex: self.orderRegex)
        if order.count > 0 {
            return RE.replace(validateString: s, withContent: "", inRegex: self.orderRegex+"[ ]*")
        }
        // This would be auto reordered, using `1.` works fine.
        return "1. "+s
    }
    
    static func updateBullet(s: String) -> String {
        if s == "\n" {return s+"- "}
        let bullet = RE.regularExpression(validateString: s, inRegex: self.bulletRegex)
        if bullet.count > 0 {
            return RE.replace(validateString: s, withContent: "", inRegex: self.bulletRegex+"[ ]*")
        }
        return "- "+s
    }
    
    // MARK: Util Functions
    
    static func autoOrder(content: String) -> [Replaced] {
        var result:[Replaced] = []
        for parsed in RE.regularExpressionRange(validateString: content, inRegex: self.orderListBlockRegex) {
            let replaced = RE.replace(validateString: parsed.content, withContent: "", inRegex: "(?<=(^|\n))[0-9]+")
            var splited = replaced.split(separator: "\n")
            splited = splited.enumerated().map({(i, line) in "\(i+1)"+line})
            let s = splited.joined(separator: "\n")
            guard let subRange = Range(parsed.range, in: content) else {continue}
            result.append(Replaced(string: s, range: subRange))
        }
        return result
    }
    
    static func getHeaderLevel(header: String) -> Int {
        guard let signs = RE.regularExpression(validateString: header, inRegex: "^#{1,3}").first else { return 0 }
        return signs.count
    }
    
    // MARK: - Attributes
    
    private static func headerAttribute(level: Int) -> [NSAttributedString.Key: Any] {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacingBefore = PARAGRAGH_LEVELS[level]
        paraStyle.paragraphSpacing = PARAGRAGH_LEVELS[level]
        let font = UIFont.boldSystemFont(ofSize: FONT_LEVELS[level])
        return [
            .font: font,
            .paragraphStyle: paraStyle,
            .foregroundColor: UIColor.label
        ]
    }
    
    private static func listAttribute() -> [NSAttributedString.Key: Any] {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.firstLineHeadIndent = 5
        paraStyle.paragraphSpacingBefore = 3
        paraStyle.paragraphSpacing = 3
        return [
            .font: UIFont.systemFont(ofSize: FONT_LEVELS[0]),
            .paragraphStyle: paraStyle,
            .foregroundColor: UIColor.label
        ]
    }
    
    private static func normalAttribute() -> [NSAttributedString.Key: Any] {
        return [
            .font: UIFont.systemFont(ofSize: FONT_LEVELS[0]),
            .foregroundColor: UIColor.label
        ]
    }
    
}

//
//  Memo.swift
//  TapMemo for iOS
//
//  Created by 一折 on 2021/2/6.
//

import UIKit
import CoreData

final class Memo: NSObject, NSCoding {
    var title: String
    var date: String
    var content: String
    let uuid: String
    
    init(title: String, date: Date, content: String) {
        self.title = title
        self.date = date.toString()
        self.content = content
        self.uuid = UUID().uuidString
    }
    
    override init() {
        self.title = "No Title"
        self.date = Date.now().toString()
        self.content = ""
        self.uuid = UUID().uuidString
    }
    
    required init?(coder: NSCoder) {
        guard let title = coder.decodeObject(forKey: "title") as? String,
              let date = coder.decodeObject(forKey: "date") as? String,
              let content = coder.decodeObject(forKey: "content") as? String,
              let uuid = coder.decodeObject(forKey: "uuid") as? String
        else {
            return nil
        }
        self.title = title
        self.date = date
        self.content = content
        self.uuid = uuid
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.title, forKey: "title")
        coder.encode(self.date , forKey: "date")
        coder.encode(self.content, forKey: "content")
        coder.encode(self.uuid, forKey: "uuid")
    }
    
    func orm(object: NSObject) {
        object.setValue(self.title, forKey: "title")
        object.setValue(self.content, forKey: "content")
        object.setValue(self.uuid, forKey: "uuid")
        object.setValue(self.date, forKey: "date")
    }
    
    func storedKey() -> String {
        return "memo-"+self.uuid
    }
    
    func update(content: String){
        self.content = content
        self.title = MDParser.getTitle(content: content)
        self.date = Date.now().toString()
    }
    
}

extension Memo {
    static func == (aMemo: Memo, bMemo: Memo) -> Bool {
        return aMemo.uuid == bMemo.uuid
    }
}

//
//  CoreUtil.swift
//  TapMemo for iOS
//
//  Created by 一折 on 2021/2/8.
//

import UIKit
import CoreData

final class CoreUtil: NSObject {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func createMemo(title: String, content: String, date: Date) -> CoreMemo {
        let entity = NSEntityDescription.entity(forEntityName: "CoreMemo", in: self.context)
        let memo = NSManagedObject(entity: entity!, insertInto: self.context) as! CoreMemo
        memo.setValue(UUID().uuidString, forKey: "uuid")
        memo.setValue(title, forKey: "title")
        memo.setValue(content, forKey: "content")
        memo.setValue(date.toString(), forKey: "date")
        return memo
    }
    
    static func saveCoreMemo(memo: Memo) {
        guard let entity = NSEntityDescription.entity(forEntityName: "CoreMemo", in: self.context) else {return}
        let newMemo = NSManagedObject(entity: entity, insertInto: self.context)
        newMemo.setValue(memo.uuid, forKey: "uuid")
        newMemo.setValue(memo.title, forKey: "title")
        newMemo.setValue(memo.content, forKey: "content")
        newMemo.setValue(memo.date, forKey: "date")
        do {
            try self.context.save()
        } catch {
            print("\(memo.title) saved failed")
        }
    }
    
    static func save() {
        do {
            try self.context.save()
        } catch {
            print("Store failed")
        }
    }
    
    static func removeMemo(memo: CoreMemo) {
        do {
            self.context.delete(memo)
            try self.context.save()
        } catch {
            print("Delete \(memo.title ?? "nil") failed")
        }
    }
    
    static func getCoreMemos() -> [CoreMemo] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreMemo")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.returnsObjectsAsFaults = false
        do {
            print("------")
            let result = try context.fetch(request) as! [CoreMemo]
            for data in result {
               print(data.value(forKey: "uuid") as! String, data.value(forKey: "date") as! String)
            }
            return result
            
        } catch {
            print("Load Failed")
            return []
        }
    }
    
}

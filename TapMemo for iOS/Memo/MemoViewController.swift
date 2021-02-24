//
//  MemoViewController.swift
//  TapMemo for iOS
//
//  Created by 一折 on 2021/2/6.
//

import UIKit
import CoreData

class MemoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    var isEdited = false
//    var memo: CoreMemo = CoreUtil.createMemo(title: "Title", content: "# Title\n", date: Date.now())
    var memo: CoreMemo?
    var token: NSPersistentHistoryToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addToolBar()

        if let memo = self.memo {
            self.textView.text = memo.content
        } else {
            self.textView.text = "# Title\n"
            self.navigationItem.title = "Title"
        }
        self.refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRemoteData(_:)), name: .NSPersistentStoreRemoteChange, object: CoreUtil.container.persistentStoreCoordinator)
        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isEdited = true
        self.textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.isEdited {
            CoreUtil.save()
        }
        self.textView.resignFirstResponder()
        NotificationCenter.default.post(name: .memosShouldUpdate, object: nil, userInfo: [:])
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if self.memo == nil {
            self.memo = CoreUtil.createMemo(title: "Title", content: "# Title\n", date: Date.now())
        }
        self.memo!.update(content: self.textView.text)
        if self.textView.markedTextRange == nil {
            self.refresh()
        }
    }
    
    final func refresh() {
        if let memo = self.memo {
            self.navigationItem.title = memo.title
        }
        let selectedRange = self.textView.selectedRange
        let textStorage = self.textView.textStorage
        textStorage.setAttributedString(MDParser.renderAll(content: self.textView.text))
        self.textView.selectedRange = selectedRange
    }
    
    func addToolBar() {
        guard let toolBar = UINib(nibName: "KeyboardToolBar", bundle: nil).instantiate(withOwner: self, options: nil).first as? KeyboardToolBar else { return }
        toolBar.headerButton.action = #selector(self.headerAction)
        toolBar.orderButton.action = #selector(self.orderAction)
        toolBar.bulletButton.action = #selector(self.bulletAction)
        toolBar.doneButton.action = #selector(self.doneAction(_:))
        self.textView.inputAccessoryView = toolBar
    }

    final func findParaHeader() -> UITextPosition? {
        guard let range = self.textView.selectedTextRange
        else { return nil }
        let position = range.start
        return self.textView.tokenizer.position(from: position, toBoundary: .paragraph, inDirection: UITextDirection(rawValue: UITextStorageDirection.backward.rawValue))
    }
    
    final func findParaEnd() -> UITextPosition? {
        guard let range = self.textView.selectedTextRange
        else { return nil }
        let position = range.start
        return self.textView.tokenizer.position(from: position, toBoundary: .paragraph, inDirection: UITextDirection(rawValue: UITextStorageDirection.forward.rawValue))
    }
    
    final func getLineRange() -> UITextRange? {
        guard let range = self.textView.selectedTextRange
        else { return nil }
        let position = range.start
        var start = self.textView.tokenizer.position(from: position, toBoundary: .paragraph, inDirection: UITextDirection(rawValue: UITextStorageDirection.backward.rawValue))
        if start == nil {
            start = self.textView.beginningOfDocument
        }
        var end = self.textView.tokenizer.position(from: position, toBoundary: .paragraph, inDirection: UITextDirection(rawValue: UITextStorageDirection.forward.rawValue))
        if end == nil {
            end = self.textView.endOfDocument
        }
        return self.textView.textRange(from: start!, to: end!)
    }
    
    @objc func handleRemoteData(_ notification:Notification) {
        guard let info = notification.userInfo,
              let token = info["historyToken"] as? NSPersistentHistoryToken,
              token != self.token
        else {
            return
        }
        let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.token)
        self.token = token
        let context = CoreUtil.container.viewContext
        guard
            let historyResult = try? context.execute(fetchHistoryRequest)
                as? NSPersistentHistoryResult,
            let history = historyResult.result as? [NSPersistentHistoryTransaction]
        else {
            print("Could not convert history result to transactions.")
            return
        }
        guard history.count > 0,
              let trans = history.last
        else {
            return
        }
        CoreUtil.context.perform {
            CoreUtil.context.mergeChanges(fromContextDidSave: trans.objectIDNotification())
            DispatchQueue.main.async {
                [unowned self] in
                guard let memo = self.memo else {return}
                self.textView.text = memo.content
                self.refresh()
            }
        }
    }
    
    @objc func headerAction() {
        guard let range = self.getLineRange(),
              let text = self.textView.text(in: range)
        else {
            return
        }
        self.textView.replace(range, withText: MDParser.updateHeader(s: text))
    }
    
    @objc func orderAction() {
        guard let range = self.getLineRange(),
              let text = self.textView.text(in: range)
        else {
            return
        }
        self.textView.replace(range, withText: MDParser.updateOrder(s: text))
    }
    
    @objc func bulletAction() {
        guard let range = self.getLineRange(),
              let text = self.textView.text(in: range)
        else {
            return
        }
        self.textView.replace(range, withText: MDParser.updateBullet(s: text))
    }

    @IBAction @objc func doneAction(_ sender: Any) {
        self.textView.endEditing(true)
    }
}

//
//  MemoViewController.swift
//  TapMemo for iOS
//
//  Created by 一折 on 2021/2/6.
//

import UIKit

class MemoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: MemoTextView!
    var memo: Memo = Memo(title: "Title", date: Date.now(), content: "# Title\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.text = memo.content
        self.addToolBar()
        self.refresh()
        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        Storage.saveMemo(memo: self.memo)
        self.textView.resignFirstResponder()
        NotificationCenter.default.post(name: .memosShouldUpdate, object: nil, userInfo: [:])
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.memo.update(content: self.textView.text)
        if self.textView.markedTextRange == nil {
            self.refresh()
        }
    }
    
    final func refresh() {
        self.navigationItem.title = self.memo.title
        let selectedRange = self.textView.selectedRange
        for replaced in MDParser.autoOrder(content: self.textView.text) {
            self.textView.text.replaceSubrange(replaced.range, with: replaced.string)
        }
        let textStorage = self.textView.textStorage
        textStorage.setAttributedString(MDParser.renderAll(content: self.textView.text))
        self.textView.selectedRange = selectedRange
    }
    
    func addToolBar() {
        guard let toolBar = UINib(nibName: "KeyboardToolBar", bundle: nil).instantiate(withOwner: self, options: nil).first as? KeyboardToolBar else { return }
        toolBar.headerButton.action = #selector(self.headerAction)
        toolBar.orderButton.action = #selector(self.orderAction)
        toolBar.bulletButton.action = #selector(self.bulletAction)
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
        guard let start = self.textView.tokenizer.position(from: position, toBoundary: .paragraph, inDirection: UITextDirection(rawValue: UITextStorageDirection.backward.rawValue)),
              let end = self.textView.tokenizer.position(from: position, toBoundary: .paragraph, inDirection: UITextDirection(rawValue: UITextStorageDirection.forward.rawValue))
        else {
            return nil
        }
        return self.textView.textRange(from: start, to: end)
    }
    
    @objc func headerAction() {
        guard let range = self.getLineRange(),
              let text = self.textView.text(in: range)
        else {return}
        self.textView.replace(range, withText: MDParser.updateHeader(s: text))
    }
    
    @objc func orderAction() {
        guard let range = self.getLineRange(),
              let text = self.textView.text(in: range)
        else {return}
        self.textView.replace(range, withText: MDParser.updateOrder(s: text))
    }
    
    @objc func bulletAction() {
        guard let range = self.getLineRange(),
              let text = self.textView.text(in: range)
        else {return}
        self.textView.replace(range, withText: MDParser.updateBullet(s: text))
    }

    @IBAction func doneAction(_ sender: Any) {
        self.textView.endEditing(true)
    }
}

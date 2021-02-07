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
        self.refresh()
    }
    
    func refresh() {
        self.navigationItem.title = self.memo.title
        let selectedRange = self.textView.selectedRange
        for replaced in MDParser.autoOrder(content: self.textView.text) {
            self.textView.text.replaceSubrange(replaced.range, with: replaced.string)
        }
        let textStorage = self.textView.textStorage
        textStorage.setAttributedString(MDParser.renderAll(content: self.textView.text))
        self.textView.selectedRange = selectedRange
    }
    

}

//
//  MemoTableViewController.swift
//  TapMemo for iOS
//
//  Created by 一折 on 2021/2/6.
//

import UIKit
import CoreData

class MemoTableViewController: UITableViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var memos: [CoreMemo] = []
    
    var recentCount: Int {
        get {
            return self.memos.filter({
                memo in
                Date.isRecentWeek(dateString: memo.date!)
            }).count
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.memos = CoreUtil.getCoreMemos() {
            self.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMemos), name: .memosShouldUpdate, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleRemoteData(_:)),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: CoreUtil.container.persistentStoreCoordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let recent = self.recentCount
        let last = self.memos.count - recent
        if recent > 0 && last > 0 {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let recent = self.recentCount
        let last = self.memos.count - recent
        if recent > 0 && last > 0 {
            return section == 0 ? recent : last
        } else if recent == 0 && last == 0 {
            return 0
        } else if recent > 0 {
            return recent
        } else {
            return last
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let memo = self.memos[self.getMemoIndex(indexPath: indexPath)]
        cell.textLabel?.text = memo.title
        cell.detailTextLabel?.text = memo.date
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Recent": "Week Ago"
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            _, _, _ in
            let index = self.getMemoIndex(indexPath: indexPath)
            let memo = self.memos[index]
            CoreUtil.removeMemo(memo: memo)
            self.memos.remove(at: index)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = self.memos[self.getMemoIndex(indexPath: indexPath)]
        self.showMemoViewController(memo: memo)
        
    }
    
    // MARK: - Notifications
    
    @objc func handleRemoteData(_ notification: Notification) {
        guard let info = notification.userInfo,
              let token = info["historyToken"] as? NSPersistentHistoryToken,
              token != CoreUtil.lastToken
        else {
            return
        }
        guard let trans = CoreUtil.getLatestTransaction(token: token) else {return}
        CoreUtil.context.perform {
            CoreUtil.context.mergeChanges(fromContextDidSave: trans.objectIDNotification())
            DispatchQueue.main.async {
                [unowned self] in
                print("update table from remote")
                self.memos = CoreUtil.getCoreMemos()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - actions
    
    @IBAction func addAction(_ sender: Any) {
    }
    
    func getMemoIndex(indexPath: IndexPath) -> Int {
        return indexPath.section * recentCount + indexPath.row
    }
    
    func showMemoViewController(memo: CoreMemo) {
        guard let memoViewController = storyboard?.instantiateViewController(withIdentifier: "Memo") as? MemoViewController,
              let navigationController = self.navigationController
        else {return}
        memoViewController.memo = memo
        navigationController.pushViewController(memoViewController, animated: true)
    }
    
    @objc func updateMemos() {
        self.memos = CoreUtil.getCoreMemos() {
            self.tableView.reloadData()
        }
    }
    
}

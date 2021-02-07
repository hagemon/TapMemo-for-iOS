//
//  SettingsTableViewController.swift
//  TapMemo for iOS
//
//  Created by 一折 on 2021/2/6.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var isLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.isLogin ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier: String
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            identifier = "accounts"
        case (1, 0):
            identifier = "sync"
        case (1, 1):
            identifier = "quit"
        default:
            identifier = "quit"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if indexPath.section == 0 && indexPath.row == 0 {
            if isLogin {
                cell.textLabel?.text = "username@apple.com"
            } else {
                cell.textLabel?.text = "Login with Apple"
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "ACCOUNTS" : "SETTINGS"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard !self.isLogin else {return}
            self.isLogin = true
            self.tableView.reloadData()
        } else if indexPath.section == 1 && indexPath.row == 1 {
            guard self.isLogin else {
                return
            }
            self.isLogin = false
            self.tableView.reloadData()
        }
    }

}

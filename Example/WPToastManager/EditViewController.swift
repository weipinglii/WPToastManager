//
//  EditViewController.swift
//  ToastManager_Example
//
//  Created by weiping.lii on 2023/4/22.
//  Copyright © 2023 weiping.lii@icloud.com. All rights reserved.
//

import UIKit

class EditViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(onCancelTapped(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(onDoneTapped(sender:)))
        self.tableView.register(EditCell.self, forCellReuseIdentifier: "ToastDebugEditCell")
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    var debugInfo = DebugInfo()
    
    var callback: ((DebugInfo) -> Void)?
    
    @objc func onCancelTapped(sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDoneTapped(sender: Any?) {
        if let cb = callback {
            cb(debugInfo)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //  MARK: - haha
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToastDebugEditCell", for: indexPath) as! EditCell
        var text1 = ""
        var text2 = ""
        switch indexPath.row {
        case 0:
            text1 = "type"
            text2 = debugInfo.type
            cell.callback = { [weak self] (text: String) -> Void in
                self?.debugInfo.type = text
            }
            cell.textField.keyboardType = .asciiCapable;
        case 1:
            text1 = "title"
            text2 = debugInfo.title
            cell.callback = { [weak self] (text: String) -> Void in
                self?.debugInfo.title = text
            }
            cell.textField.keyboardType = .asciiCapable
        case 2:
            text1 = "open URL"
            text2 = debugInfo.schemeURL?.absoluteString ?? " "
            cell.callback = { [weak self] (text: String) -> Void in
                self?.debugInfo.schemeURL = URL(string: text)
            }
            cell.textField.keyboardType = .URL
        case 3:
            text1 = "displayTime"
            text2 = String(describing: debugInfo.displayTime)
            cell.callback = { [weak self] (text: String) -> Void in
                let string = text as NSString
                self?.debugInfo.displayTime = max(string.doubleValue, 0.5)
            }
            cell.textField.keyboardType = .decimalPad;
        case 4:
            text1 = "custom toast"
            text2 = String(describing: debugInfo.customCellClass)
            cell.callback = { [weak self] (text: String) -> Void in
                self?.debugInfo.customCellClass = text
            }
            cell.textField.keyboardType = .asciiCapable;
        default:
            break
        }
        cell.label.text = text1
        cell.textField.text = text2
        cell.textField.autocapitalizationType = .none
        cell.textField.autocorrectionType = .no
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

//
//  EditCell.swift
//  ToastManager_Example
//
//  Created by weiping.lii on 2023/4/22.
//  Copyright © 2023 weiping.lii@icloud.com. All rights reserved.
//

import UIKit

class EditCell: UITableViewCell {

    var callback: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(label)
        contentView.addSubview(textField)
        
        label.translatesAutoresizingMaskIntoConstraints = false;
        textField.translatesAutoresizingMaskIntoConstraints = false;
        
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3).isActive = true
        
        textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        textField.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
        textField.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        textField.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var textField: UITextField = {
        let view = UITextField()
        view.clearButtonMode = .whileEditing
        view.backgroundColor = UIColor.lightGray
        view.delegate = self
        view.addTarget(self, action: #selector(textDidChanged(_:)), for: .editingChanged)
        return view
    }()
}

extension EditCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func textDidChanged(_ sender: UITextField) {
        
        if let callback = callback {
            callback(textField.text ?? "")
        }
    }
}

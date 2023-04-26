//
//  MessageCell.swift
//  ToastManager_Example
//
//  Created by weiping.lii on 2023/4/22.
//  Copyright © 2023 weiping.lii@icloud.com. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true;
        view.numberOfLines = 0;
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor(displayP3Red: CGFloat.random(in: 0.5...1),
                                              green:  CGFloat.random(in: 0.5...1),
                                              blue:  CGFloat.random(in: 0.5...1),
                                              alpha: 1)
        label.frame = contentView.frame
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

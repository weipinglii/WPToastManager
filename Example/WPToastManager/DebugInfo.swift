//
//  DebugInfo.swift
//  ToastManager_Example
//
//  Created by weiping.lii on 2023/4/22.
//  Copyright © 2023 weiping.lii@icloud.com. All rights reserved.
//

import UIKit

class DebugInfo: NSObject, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(type, forKey: "type")
        coder.encode(title, forKey: "title")
        coder.encode(schemeURL, forKey: "schemeURL")
        coder.encode(displayTime, forKey: "displayTime")
        coder.encode(customCellClass, forKey: "customCellClass")
    }
    
    required init?(coder: NSCoder) {
        super.init()
        type = coder.decodeObject(forKey: "type") as? String ?? "debug"
        title = coder.decodeObject(forKey: "title") as? String ?? "default"
        schemeURL = coder.decodeObject(forKey: "schemeURL") as? URL ?? URL(string: "demo-WPToastManager://default")
        displayTime = coder.decodeDouble(forKey: "displayTime")
        customCellClass = coder.decodeObject(forKey: "customCellClass") as? String
    }
    
    override init() {
        super.init()
    }
    
    var type: String = "debug"
    var title: String = "Test Tessage"
    var subtitle: String? {
        return "type: \(type), displayTime:\(displayTime)"
    }
    var schemeURL: URL? = URL(string: "demo-WPToastManager://default")!
    var displayTime: Double = 5.0
    var customCellClass: String?
    var imageURL: URL? =  URL(string: "https://t10.baidu.com/it/u=3429596863,168877722&fm=30&app=106&f=JPEG?w=307&h=129&s=9A8A70239B947DC01CFDB5CE010080B1")
    
    override var description: String {
        let str = """
        type:\(type)
        title:\(title)
        subtitle:\(subtitle ?? "")
        scheme:\(String(describing: schemeURL))
        displayTime:\(displayTime)
        """
        return str
    }
}

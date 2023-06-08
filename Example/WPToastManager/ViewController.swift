//
//  ViewController.swift
//  ToastManager_Example
//
//  Created by weiping.lii on 2023/4/22.
//  Copyright © 2023 weiping.lii@icloud.com. All rights reserved.
//

import WPToastManager

@objc public class ViewController: UIViewController, UICollectionViewDataSource {
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        view.delegate = self;
        view.dataSource = self;
        return view
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Custom Toast Messages"
        self.view.addSubview(self.collectionView);
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let btn1 = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(onClearBtnTapped(_:)))
        let btn2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddBtnTapped(_:)))
        navigationItem.setRightBarButtonItems([btn2, btn1], animated: true)
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "cell")
        WPToastCenter.shared.delegate = self;
        loadPresetDebugInfo()
    }
    
    func loadPresetDebugInfo() {
        //  MARK: - control info
        let info = WPToastControlInfo()
        info.type = "debug"
        info.interval = 3
        info.expiration = 10
        info.priority = 1
        
        let info1 = WPToastControlInfo()
        info1.type = "debug1"
        info1.interval = 1
        info1.expiration = 10
        info1.priority = 10
        
        let info2 = WPToastControlInfo()
        info2.type = "debug2"
        info2.interval = 0
        info2.expiration = 10
        info2.priority = 20
        
        WPToastCenter.shared.loadControlInfo([info, info1, info2])
        
        //  MARK: - preset toast
        let type1 = DebugInfo()
        messages.append(type1)
        
        let type2 = DebugInfo()
        type2.type = "debug1"
        messages.append(type2)
        
        let type3 = DebugInfo()
        type3.type = "debug2"
        messages.append(type3)
    }
    
    static var count: Int = 0
    
    lazy var messages: [DebugInfo] = {
        let arr = Array<DebugInfo>()
        return arr
    }()
    
    @objc func onAddBtnTapped(_ sender: Any) {
        let vc = EditViewController()
        vc.callback = { (info) -> () in
            self.messages.append(info)
            self.collectionView.reloadData()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    @objc func onClearBtnTapped(_ sender: Any) {
        self.messages.removeAll()
        self.collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.label.text =  String(describing: message)
        if indexPath.item == 0 {
            cell.contentView.backgroundColor = UIColor.orange
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ViewController.count += 1
        let info = messages[indexPath.row]
        let message = WPToastMessage()
        message.type = info.type
        message.title = info.title.count > 0 ? ("\(ViewController.count)" + info.title) : ""
        message.subtitle = info.subtitle
        message.displayTime = info.displayTime
        message.schemeURL = info.schemeURL
        message.imageURL = info.imageURL
        if let string = info.customCellClass, let custom = NSClassFromString(string) {
            message.customToastClass = custom
        }
        WPToastCenter.shared.push(message)
    }
    
    let margin: CGFloat = 5;
    lazy var width: CGFloat = floor((UIScreen.main.bounds.width - margin * 3) / 2)
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
}

extension ViewController: WPToastEventDelegate {
    
    @objc public func toastCenter(_ manager: WPToastCenter, callbackFor message: WPToastMessageProtocol, lifeCycleEvent event: WPToastMessageLifeCycle, eventDesc: String?) {
        
        print(message.type(), event.rawValue, eventDesc ?? "")
    }
}


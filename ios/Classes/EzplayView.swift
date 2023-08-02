//
//  EzplayView.swift
//  ezplay_camera
//
//  Created by rem on 2023/8/2.
//

import Foundation
import Flutter
import UIKit

class EZUIPlayerView: NSObject, FlutterPlatformView  {
    private var _view: UIView
    
    override init() {
        self._view = UIView()
        self._view.backgroundColor = UIColor.blue
        let nativeLabel = UILabel()
//        nativeLabel.text = "Native text from iOS"
        nativeLabel.textColor = UIColor.black
        nativeLabel.textAlignment = .center
        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
        _view.addSubview(nativeLabel)
        super.init()
    }
    func view() -> UIView {
        return _view;
    }
    
}

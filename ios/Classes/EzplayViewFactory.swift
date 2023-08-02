//
//  EzplayViewFactory.swift
//  ezplay_camera
//
//  Created by rem on 2023/8/2.
//

import Foundation
import UIKit
import Flutter

class EZUIPlayerViewFactory :NSObject,FlutterPlatformViewFactory{
    private var messenger: FlutterBinaryMessenger
    var views: [Int64: UIView] = [:]
        init (messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            super.init()
        }

        func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
            let view = EZUIPlayerView()
            views[viewId] = view.view()
            return view
        }
}

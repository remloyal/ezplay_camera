import Flutter
import UIKit
import EZOpenSDKFramework


public class EzplayCameraPlugin: NSObject, FlutterPlugin {
    
  public static func register(with binding: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ezplay_camera", binaryMessenger: binding.messenger())
    let instance = EzplayCameraPlugin()
      
      print("测少时诵诗书少时诵诗书飒飒飒")
//      let factory = FlutterMethodChannel(name: "ezplay_view", binaryMessenger: binding.messenger())
      let factory =    EZUIPlayerViewFactory(messenger: binding.messenger())
      binding.register(factory, withId: "ezplay_view")
      
      binding.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      
    switch call.method {
    case "setLogEnabled":
        let enable:Bool = (call.arguments != nil);
        if(enable ){
            EZOpenSDK.setDebugLogEnable(enable);
        }
        result(enable);
    case "initAppKey":
        let  app_key:String = call.arguments as! String;
        let b:Bool = EZOpenSDK.initLib( withAppKey: app_key);
        result(b);
    case "setAccessToken":
        let  AccessToken:String = call.arguments as! String;
        EZOpenSDK.setAccessToken(AccessToken);
        result(true);
    case "destroyLib":
        print("测少时诵诗书少时诵诗书飒飒飒")
//        EZOpenSDK.finiLib();
        
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

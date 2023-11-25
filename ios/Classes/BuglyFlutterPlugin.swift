import Flutter
import UIKit
import Bugly

public class BuglyFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "temoa/bugly_flutter", binaryMessenger: registrar.messenger())
    let instance = BuglyFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initCrashReport":
      let arguments = call.arguments as! Dictionary<String, Any>
      let iOSAppId = arguments["iOSAppId"] as! String
      let debug = arguments["debug"] as! Bool
      
      let deviceId = arguments["deviceId"] as? String
      let appChannel = arguments["appChannel"] as? String
      let appVersion = arguments["appVersion"]as? String
      let isDevelopmentDevice = arguments["isDevelopmentDevice"] as! Bool
      
      let config = BuglyConfig()
      if(deviceId != nil){
        config.deviceIdentifier = deviceId!
      }
      if(appChannel != nil){
        config.channel = appChannel!
      }
      if(appVersion != nil){
        config.version = appVersion!
      }
      if(appVersion != nil){
        config.version = appVersion!
      }
      
      Bugly.start(withAppId: iOSAppId, developmentDevice: isDevelopmentDevice, config: config)
      result(nil)
      break;
    case "postCaughtException":
      let arguments = call.arguments as! Dictionary<String, Any>
      let crashMessage = arguments["crashMessage"] as! String
      
      let crashDetail = arguments["crashDetail"] as! String
      let stackTraceArray = crashDetail.components(separatedBy: "")
      
      var data = arguments["crashData"] as? [AnyHashable : Any]
      if data == nil {
          data = [:]
      }
      Bugly.reportException(withCategory: 5, name: "Flutter Exception", reason: crashMessage, callStack: stackTraceArray, extraInfo: data!, terminateApp:false)
      result(nil)
      break;
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

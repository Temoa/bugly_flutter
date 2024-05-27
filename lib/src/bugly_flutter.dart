part of bugly_flutter;

class BuglyFlutter {
  static const tag = "bugly_flutter";

  static const MethodChannel _methods = MethodChannel("temoa/bugly_flutter");

  static bool _postCaught = false;

  BuglyFlutter._();

  static Future<void> initCrashReport(
    String androidAppId,
    String iOSAppId,
    bool debug, {
    String? deviceId, // 设置设备 id
    String? deviceModel, // 设置设备型号
    String? appChannel, // 设置 App 版本、渠道、包名
    String? appVersion,
    String? packageName,
    int reportDelay = 10 * 1000, // 设置 Bugly 初始化延迟
    bool enableCatchAnrTrace = false, // 设置 anr trace 采集
    bool enableRecordAnrMainStack = true,
    bool allThreadStackCrashEnable = true, // 设置 crash 和 anr 时是否获取全部堆栈
    bool allThreadStackAnrEnable = true,
    int? userSceneTag, // 设置标签
    bool isDevelopmentDevice = true, // 设置开发设备
  }) async {
    assert((Platform.isAndroid && androidAppId.isNotEmpty) || (Platform.isIOS && iOSAppId.isNotEmpty));
    assert(_postCaught, "Run postCaughtException first.");
    return _methods.invokeMethod("initCrashReport", {
      "androidAppId": androidAppId,
      "iOSAppId": iOSAppId,
      "debug": debug,
      "deviceId": deviceId,
      "deviceModel": deviceModel,
      "appChannel": appChannel,
      "appVersion": appVersion,
      "packageName": packageName,
      "reportDelay": reportDelay,
      "enableCatchAnrTrace": enableCatchAnrTrace,
      "enableRecordAnrMainStack": enableRecordAnrMainStack,
      "allThreadStackCrashEnable": allThreadStackCrashEnable,
      "allThreadStackAnrEnable": allThreadStackAnrEnable,
      "userSceneTag": userSceneTag,
      "isDevelopmentDevice": isDevelopmentDevice,
    });
  }

  static Future<void> testJavaCrash() async {
    return _methods.invokeMethod("testJavaCrash");
  }

  /// from https://github.com/crazecoder/flutter_bugly
  static void postCaughtException<T>(
    T Function() callback, {
    FlutterExceptionHandler? onException,
    bool debugUpload = false,
  }) {
    Isolate.current.addErrorListener(RawReceivePort((dynamic pair) {
      var isolateError = pair as List<dynamic>;
      var error = isolateError.first;
      var stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(error, stackTrace);
    }).sendPort);
    // This captures errors reported by the Flutter framework.
    FlutterError.onError = (details) {
      if (details.stack != null) {
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      } else {
        FlutterError.presentError(details);
      }
    };
    _postCaught = true;
    runZonedGuarded<Future<void>>(() async {
      callback();
    }, (error, stackTrace) {
      _filterAndUploadException(
        debugUpload,
        onException,
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    });
  }

  /// from https://github.com/crazecoder/flutter_bugly
  static void _filterAndUploadException(bool debugUpload, FlutterExceptionHandler? handler, FlutterErrorDetails details) {
    if (handler != null) {
      handler(details);
    } else {
      FlutterError.onError?.call(details);
    }
    if (!debugUpload) return;
    uploadException(message: details.exception.toString(), detail: details.stack.toString());
  }

  /// from https://github.com/crazecoder/flutter_bugly
  /// 上报自定义异常信息，data 为文本附件
  /// Android 错误分析 => 跟踪数据 => extraMessage.txt
  /// iOS 错误分析 => 跟踪数据 => crash_attach.log
  static Future<void> uploadException({
    required String message,
    required String detail,
    Map<String, String>? data,
  }) async {
    var map = {};
    map.putIfAbsent("crashMessage", () => message);
    map.putIfAbsent("crashDetail", () => detail);
    if (data != null) map.putIfAbsent("crashData", () => data);
    await _methods.invokeMethod("postCaughtException", map);
  }
}

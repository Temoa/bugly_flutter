package me.temoa.bugly_flutter

import android.content.Context
import com.tencent.bugly.crashreport.CrashReport
import com.tencent.bugly.crashreport.CrashReport.UserStrategy
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** BuglyFlutterPlugin */
class BuglyFlutterPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var context: Context
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "temoa/bugly_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initCrashReport" -> {
        initCrashReport(call, result)
      }

      "testJavaCrash" -> {
        CrashReport.testJavaCrash()
        result.success(null)
      }

      "postCaughtException" -> {
        postCaughtException(call, result)
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initCrashReport(call: MethodCall, result: Result) {
    val androidAppId = call.argument<String>("androidAppId")!!
    val debug = call.argument<Boolean>("debug")!!

    val deviceId = call.argument<String>("deviceId")
    val deviceModel = call.argument<String>("deviceModel")
    val appChannel = call.argument<String>("appChannel")
    val appVersion = call.argument<String>("appVersion")
    val packageName = call.argument<String>("packageName")
    val reportDelay = call.argument<Int>("reportDelay")!!
    val enableCatchAnrTrace = call.argument<Boolean>("enableCatchAnrTrace")!!
    val enableRecordAnrMainStack = call.argument<Boolean>("enableRecordAnrMainStack")!!
    val allThreadStackCrashEnable = call.argument<Boolean>("allThreadStackCrashEnable")!!
    val allThreadStackAnrEnable = call.argument<Boolean>("allThreadStackAnrEnable")!!
    val userSceneTag = call.argument<Int>("userSceneTag")
    val isDevelopmentDevice = call.argument<Boolean>("isDevelopmentDevice")!!

    val strategy = UserStrategy(context).apply {
      deviceId?.let { deviceID = it }
      deviceModel?.let { setDeviceModel(it) }
      appChannel?.let { setAppChannel(it) }
      appVersion?.let { setAppVersion(it) }
      packageName?.let { appPackageName = it }
      appReportDelay = reportDelay.toLong()
      isEnableCatchAnrTrace = enableCatchAnrTrace
      isEnableRecordAnrMainStack = enableRecordAnrMainStack
    }

    CrashReport.initCrashReport(context, androidAppId, debug, strategy)
    CrashReport.setIsDevelopmentDevice(context, isDevelopmentDevice)
    CrashReport.setAllThreadStackEnable(context, allThreadStackCrashEnable, allThreadStackAnrEnable)
    userSceneTag?.let { CrashReport.setUserSceneTag(context, it) }

    result.success(null)
  }

  private fun postCaughtException(call: MethodCall, result: Result) {
    val crashMessage = call.argument<String>("crashMessage")!!
    val crashDetail = call.argument<String>("crashDetail")!!
    val crashData = call.argument<Map<String, String>>("crashData")
    CrashReport.postException(8, "Flutter Exception", crashMessage, crashDetail, crashData)
    result.success(null)
  }
}

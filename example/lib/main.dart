import 'package:bugly_flutter/bugly_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  BuglyFlutter.postCaughtException(() {
    runApp(const MyApp());
    BuglyFlutter.initCrashReport("androidAppId", "iOSAppId", false);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}

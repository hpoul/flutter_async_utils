import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_async_utils/flutter_async_utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

Future<void> _wait(int seconds) async {
  await Future<void>.delayed(Duration(seconds: seconds));
}

class _MyAppState extends State<MyApp> with FutureTaskStateMixin {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 160),
              const Text('Example App ;-)\n'),
              RaisedButton(
                child: const Text('Tap me.'),
                onPressed: asyncTaskCallback((progress) async {
                  await _wait(1);
                  progress.progressLabel = 'Doing more work';
                  await _wait(2);
                  progress.progressLabel = 'And even more.';
                  await _wait(3);
                }),
              ),
              ...?task == null
                  ? null
                  : [
                      const CircularProgressIndicator(),
                      Text(task.progressLabel ?? ''),
                    ],
            ],
          ),
        ),
      ),
    );
  }
}

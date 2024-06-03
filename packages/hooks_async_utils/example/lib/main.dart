import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_async_utils/hooks_async_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final incrementTask = useAsyncTask();
    final count = useState(0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example App'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incrementTask.asyncTaskCallback((progress) async {
          progress.progressLabel = 'Doing something exciting..';
          await Future.delayed(const Duration(seconds: 2));
          progress.progressLabel = 'Almost done.';
          await Future.delayed(const Duration(seconds: 1));
          count.value = count.value + 1;
        }),
        child: incrementTask.task == null
            ? const Icon(Icons.add)
            : const CircularProgressIndicator(),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...?(() {
              final task = incrementTask.task;
              if (task == null) {
                return null;
              }
              return <Widget>[
                Text(task.progressLabel ?? 'Doing work'),
              ];
            })(),
            Text(count.value.toString()),
          ],
        ),
      ),
    );
  }
}

## Hooks async utils

Create a task hook using: `final incrementTask = useAsyncTask();` and use it to
create a callback which will prevent double clicking as long as the async function is running:

```dart
      floatingActionButton: FloatingActionButton(
        onPressed: incrementTask.asyncTaskCallback((progress) async {
          progress.progressLabel = 'Doing something exciting..';
          await Future.delayed(const Duration(seconds: 2));
          progress.progressLabel = 'Almost done.';
          await Future.delayed(const Duration(seconds: 1));
          count.value = count.value + 1;
        }),
```

See [example/lib/main.dart] for details.

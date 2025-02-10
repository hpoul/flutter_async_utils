import 'package:flutter/widgets.dart';
import 'package:flutter_async_utils/flutter_async_utils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncTaskHook useAsyncTask({List<Object>? keys}) {
  // final asyncTaskHook = useMemoized(() => AsyncTaskHook());
  // return useListenable(asyncTaskHook);
  return use(_AsyncTaskHook(keys: keys));
}

typedef OnError = void Function(BuildContext context, ErrorDetails error);

abstract class AsyncTaskHook {
  static OnError defaultShowErrorDialog = (context, error) {};
  VoidCallback? asyncTaskCallback<U>(
      Future<U> Function(TaskProgress progress) progress);
  Future<U> asyncRunTask<U>(
      Future<U> Function(TaskProgress progress) taskRunner,
      {String? label});
  FutureTask? get task;

  OnError? get onError;
  set onError(OnError? onError);
}

class _AsyncTaskHook extends Hook<AsyncTaskHook> {
  const _AsyncTaskHook({super.keys});
  @override
  HookState<AsyncTaskHook, Hook<AsyncTaskHook>> createState() =>
      _AsyncTaskHookState();
}

class _AsyncTaskHookState extends HookState<AsyncTaskHook, _AsyncTaskHook>
    implements AsyncTaskHook {
  late final _manager =
      FutureTaskManager(showErrorDialog: (ErrorDetails error) {
    (onError ?? AsyncTaskHook.defaultShowErrorDialog)(context, error);
  }, onChanged: (FutureTask? task) {
    if (!context.mounted) {
      return;
    }
    setState(() {});
  });

  @override
  void initHook() {}

  @override
  AsyncTaskHook build(BuildContext context) {
    return this;
  }

  @override
  FutureTask? get task => _manager.task;

  @override
  VoidCallback? asyncTaskCallback<U>(
      Future<U> Function(TaskProgress progress) progress) {
    return _manager.asyncTaskCallback(progress);
  }

  @override
  Future<U> asyncRunTask<U>(
          Future<U> Function(TaskProgress progress) taskRunner,
          {String? label}) =>
      _manager.asyncRunTask(taskRunner, label: label);

  @override
  OnError? onError;
}

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

final _logger = Logger('future_task_state_mixin');

mixin TaskStateMixin<T extends StatefulWidget> on State<T> {
  Future<dynamic>? task;

  @protected
  VoidCallback? asyncTaskCallback<U>(Future<U> Function() callback) {
    if (task != null) {
      return null;
    }
    return () {
      asyncRunTask(callback);
    };
  }

  @protected
  Future<U> asyncRunTask<U>(Future<U> Function() taskRunner) {
    final future = taskRunner();
    setState(() {
      task = future;
    });
    future.whenComplete(() {
      if (!mounted) {
        _logger.warning('Task finished after widget was no '
            'longer mounted.');
        return;
      }
      setState(() {
        task = null;
      });
    });
    return future;
  }
}

class FutureTask with ChangeNotifier implements ValueListenable<FutureTask> {
  FutureTask({required this.future, String? progressLabel})
      : _progressLabel = progressLabel {
    _logger.info('Initialized task with $progressLabel');
  }
  final Future<dynamic> future;
  String? _progressLabel;
  set progressLabel(String? progressLabel) {
    _progressLabel = progressLabel;
    _logger.fine('Progress Label changed to $progressLabel '
        '(hasListeners: $hasListeners)');
    notifyListeners();
  }

  String? get progressLabel => _progressLabel;

  @override
  FutureTask get value => this;
}

class _TaskProgressProxy implements TaskProgress {
  late FutureTask _futureTask;
  String? _progressLabel;

  @override
  set progressLabel(String progressLabel) {
    _progressLabel = progressLabel;
    _futureTask.progressLabel = progressLabel;
    _logger.fine('proxy: label changed to $progressLabel ($_futureTask)');
  }
}

abstract class TaskProgress {
  set progressLabel(String progressLabel);
}

typedef ShowErrorDialog = void Function(
  ErrorDetails error,
);

class ErrorDetails {
  ErrorDetails(this.title, this.message, this.error);
  final String title;
  final String message;
  final dynamic error;
}

/// Mixin to make it easy to provide asynchronous callbacks for buttons, etc.
/// which show progress and prevent double tapping.
///
/// The easiest use is to assign the result of [asyncTaskCallback] to
/// a `onPressed` or `onTapped` parameter of [ListTile], [Button], etc.
/// it will return a callback, but once the callback is running returns null
/// so the button is disabled for the time the callback is running.
///
/// You can then use the [task] attribute to show Progress or even
/// show a label of the current state of the running task.
mixin FutureTaskStateMixin<T extends StatefulWidget> on State<T> {
  static ShowErrorDialog defaultShowErrorDialog = (__) {};

  FutureTask? get task => _futureTaskManager.task;

  late final FutureTaskManager _futureTaskManager = FutureTaskManager(
      onChanged: (task) {
        if (!mounted) {
          if (task == null) {
            _logger.warning('Task finished after widget was no '
                'longer mounted.');
          } else {
            _logger.warning('Task finished after widget was no '
                'longer mounted. ${task.progressLabel}');
          }
          return;
        }
        setState(() {});
      },
      showErrorDialog: showErrorDialog);

  @protected
  VoidCallback? asyncTaskCallback<U>(
          Future<U> Function(TaskProgress progress) progress) =>
      _futureTaskManager.asyncTaskCallback(progress);

  @protected
  Future<U> asyncRunTask<U>(
          Future<U> Function(TaskProgress progress) taskRunner,
          {String? label}) =>
      _futureTaskManager.asyncRunTask(taskRunner, label: label);

  ShowErrorDialog get showErrorDialog => defaultShowErrorDialog;
}

class FutureTaskManager {
  FutureTaskManager({required this.showErrorDialog, required this.onChanged});

  final ShowErrorDialog showErrorDialog;
  final void Function(FutureTask? task) onChanged;
  FutureTask? task;
  final Queue<VoidCallback> _taskQueue = Queue<VoidCallback>();

  VoidCallback? asyncTaskCallback<U>(
      Future<U> Function(TaskProgress progress) progress) {
    if (task != null) {
      return null;
    }
    return () {
      asyncRunTask(progress);
    };
  }

  Future<U> asyncRunTask<U>(
      Future<U> Function(TaskProgress progress) taskRunner,
      {String? label}) async {
    final myTask = task;
    if (myTask != null) {
      // we have to queue task.
      final taskProgressLabel = myTask.progressLabel;
      _logger.finer(
          'A task is already running ($taskProgressLabel). queuing ($label)');
      final completer = Completer<U>();
      _taskQueue.add(() {
        completer.complete(asyncRunTask(taskRunner, label: label));
      });
      return completer.future;
    }
    _logger.finer('Running task $label');
    final proxy = _TaskProgressProxy();
    final completer = Completer<U>();
    proxy._futureTask = FutureTask(
      future: completer.future,
      progressLabel: proxy._progressLabel ?? label,
    );
    proxy._futureTask.addListener(() {
      onChanged(proxy._futureTask);
    });
    task = proxy._futureTask;
    onChanged(proxy._futureTask);
    try {
      final ret = await taskRunner(proxy);
      completer.complete(ret);
      return ret;
    } catch (error, stackTrace) {
      showErrorDialog(ErrorDetails(
          'Error while ${label ?? 'running task'}', '$error', error));
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _logger.fine('Task $label completed. ${_taskQueue.length} queued'
          ' tasks remaining.');
      task = null;
      onChanged(task);
      if (_taskQueue.isNotEmpty) {
        _taskQueue.removeFirst()();
      }
    }
  }
}

extension FutureTaskStateMixinEx on FutureTaskStateMixin {
  /// Executes the given [cb] and returns it's value if there is a running task.
  /// If no task is running, returns null.
  T? withTask<T>(T Function(FutureTask task) cb) {
    final task = _futureTaskManager.task;
    if (task != null) {
      return cb(task);
    }
    return null;
  }
}

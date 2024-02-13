// based on:
// https://github.com/flutter/plugins/blob/570932f/packages/firebase_database/lib/ui/utils/stream_subscriber_mixin.dart
// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Base class which can be used as a mixin directly, but you have to call `cancelSubscriptions`.
/// If used inside a [State], use [StreamSubscriberMixin].
mixin StreamSubscriberBase {
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  /// Listens to a stream and saves it to the list of subscriptions.
  void listen(Stream<dynamic> stream, void Function(dynamic data) onData,
      {Function? onError}) {
    _subscriptions.add(stream.listen(onData, onError: onError));
  }

  void handle(StreamSubscription<dynamic> subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancels all streams that were previously added with listen().
  void cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

class StreamSubscriptions with StreamSubscriberBase {}

/// Mixin for [State] classes that own `StreamSubscription`. It will automatically call
/// [cancelSubscriptions] on [dispose].
///
/// Either use [handleSubscriptions] or directly `subscriptions.handle(...)`. to register stream subscriptions.
@optionalTypeArgs
mixin StreamSubscriberMixin<T extends StatefulWidget> on State<T> {
  final StreamSubscriptions _subscriptions = StreamSubscriptions();

  StreamSubscriptions get subscriptions => _subscriptions;

  void handleSubscription(StreamSubscription<dynamic> subscription) =>
      _subscriptions.handle(subscription);

  @mustCallSuper
  @protected
  @override
  void dispose() {
    _subscriptions.cancelSubscriptions();
    super.dispose();
  }
}

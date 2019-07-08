// based on:
// https://github.com/flutter/plugins/blob/570932f/packages/firebase_database/lib/ui/utils/stream_subscriber_mixin.dart
// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of flutter_async_utils;

/// Mixin for classes that own `StreamSubscription`s and expose an API for
/// disposing of themselves by cancelling the subscriptions
@optionalTypeArgs
mixin StreamSubscriberMixin<T extends StatefulWidget> on State<T> {
  List<StreamSubscription<dynamic>> _subscriptions = <StreamSubscription<dynamic>>[];

  /// Listens to a stream and saves it to the list of subscriptions.
  void listen(Stream<dynamic> stream, void onData(dynamic data), {Function onError}) {
    if (stream != null) {
      _subscriptions.add(stream.listen(onData, onError: onError));
    }
  }

  void handleSubscription(StreamSubscription<dynamic> subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancels all streams that were previously added with listen().
  void cancelSubscriptions() {
    _subscriptions
        .forEach((StreamSubscription<dynamic> subscription) => subscription.cancel());
    _subscriptions.clear();
  }

  @mustCallSuper
  @protected
  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }
}

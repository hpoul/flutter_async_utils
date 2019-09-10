// based on:
// https://github.com/flutter/plugins/blob/570932f/packages/firebase_database/lib/ui/utils/stream_subscriber_mixin.dart
// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Base class which can be used as a mixin directly, but you have to call `cancelSubscriptions`.
/// If used inside a [State], use [StreamSubscriberMixin].
mixin StreamSubscriberBase {
  List<StreamSubscription<dynamic>> _subscriptions = <StreamSubscription<dynamic>>[];

  /// Listens to a stream and saves it to the list of subscriptions.
  void listen(Stream<dynamic> stream, void onData(dynamic data), {Function onError}) {
    if (stream != null) {
      _subscriptions.add(stream.listen(onData, onError: onError));
    }
  }

  void handle(StreamSubscription<dynamic> subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancels all streams that were previously added with listen().
  void cancelSubscriptions() {
    _subscriptions.forEach((StreamSubscription<dynamic> subscription) => subscription.cancel());
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

  void handleSubscription(StreamSubscription<dynamic> subscription) => _subscriptions.handle(subscription);

  @mustCallSuper
  @protected
  @override
  void dispose() {
    _subscriptions.cancelSubscriptions();
    super.dispose();
  }
}

# flutter_async_utils

A few utils to make working with Streams and Futures easier. See the running example at: https://hpoul.github.io/flutter_async_utils/ ([example/lib/main.dart](./example/lib/main.dart))

## StreamSubscriberMixin

Right now not much more than an extracted version of the `StreamSubscriberMixin` of
https://github.com/flutter/plugins/blob/570932f/packages/firebase_database/lib/ui/utils/stream_subscriber_mixin.dart

## FutureTaskStateMixin

Useful for providing asynchronous callbacks to show progress and prevent double-taps.

# Work In Progress

Under heavy development. You might take a look at [AuthPass](https://authpass.app/) which
makes heavy use of those simple classes. For example [_SelectFileWidgetState][1].


[1]: https://github.com/authpass/authpass/blob/dc35b2b56793e4f6594614c2748297ccc539ad1a/authpass/lib/ui/screens/select_file_screen.dart#L152

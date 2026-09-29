import 'package:flutter/material.dart';

/// The app's outermost [ScaffoldMessenger]. Its SnackBars appear above every
/// page, including the nested navigators of the main and settings pages.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

String? _lastMessage;
DateTime _lastShownAt = DateTime.fromMillisecondsSinceEpoch(0);

/// Shows [message] as a SnackBar on top of whatever page is open.
///
/// The same message is shown at most once per few seconds, so a series of
/// failing chunks does not queue a stack of identical SnackBars.
void showAppSnackBar(String message, {bool error = false}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  final now = DateTime.now();
  if (message == _lastMessage &&
      now.difference(_lastShownAt) < const Duration(seconds: 5)) {
    return;
  }
  _lastMessage = message;
  _lastShownAt = now;
  messenger.showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: error ? Colors.red : null,
    duration: Duration(seconds: error ? 5 : 3),
  ));
}

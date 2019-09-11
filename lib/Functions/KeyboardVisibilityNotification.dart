import 'package:flutter/services.dart';
import 'dart:async';

class KeyboardVisibilityNotification {
  static const EventChannel eventChannel = const EventChannel('com.darkandjeweled.thrift/keyboard');

  static StreamSubscription streamSubscription;
  Function(bool visible) subscriber;

  KeyboardVisibilityNotification(Function(bool visible) subscriber){
    this.subscriber = subscriber;
    streamSubscription = eventChannel.receiveBroadcastStream().listen(onKeyboardEvent);
  }

  void onKeyboardEvent(dynamic arg) => subscriber((arg as int) == 1);

  void dispose() {
    streamSubscription.cancel();
  }
}
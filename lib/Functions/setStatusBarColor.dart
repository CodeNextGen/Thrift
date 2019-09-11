import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

const String method = "set";
const String foreground = "for";
const String colorValue = "col";
const MethodChannel methodChannel = const MethodChannel('com.darkandjeweled.thrift/statusbar');

Future<void> setStatusBarColor(Color color) async =>
    await methodChannel.invokeMethod(method, {
      foreground: 1.05 / (color.computeLuminance() + 0.05) > 4.5,
      colorValue: color.value,
    });
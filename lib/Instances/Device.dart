import 'dart:ui' as ui;
import 'dart:io' as io;

class Device{
  static const int device_PHONE = 0;
  static const int device_TABLET = 1;
  static const int platform_IOS = 0;
  static const int platform_ANDROID = 1;

  static double devicePixelRatio = ui.window.devicePixelRatio;

  static ui.Size size = ui.window.physicalSize;
  static double width = size.width;
  static double height = size.height;
  static double screenWidth = width / devicePixelRatio;
  static double screenHeight = height / devicePixelRatio;

  final int screen;
  final int platform;

  Device({this.screen, this.platform});

  Device get get{
    int screen;
    int platform;

    if(io.Platform.isIOS){
      platform = platform_IOS;
    } else if(io.Platform.isAndroid){
      platform = platform_ANDROID;
    }

    if((devicePixelRatio < 2 && (width >= 1000 || height >= 1000)) || devicePixelRatio == 2 && (width >= 1920 || height >= 1920)){
      screen = device_TABLET;
    } else {
      screen = device_PHONE;
    }

    return Device(screen: screen, platform: platform);
  }
}
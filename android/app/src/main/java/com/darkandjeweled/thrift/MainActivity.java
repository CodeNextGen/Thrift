package com.darkandjeweled.thrift;

import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import java.util.HashMap;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements EventChannel.StreamHandler, ViewTreeObserver.OnGlobalLayoutListener{
  public static final String keyboardEventChannel = "com.darkandjeweled.thrift/keyboard";

  public static final String statusBarColorChannel = "com.darkandjeweled.thrift/statusbar";
  public static final String setStatusBarColorMethod = "set";
  public static final String statusBarForegroundWhite = "for";
  public static final String statusBarColorValue = "col";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    registerKeyboardListener();
    new EventChannel(getFlutterView(), keyboardEventChannel).setStreamHandler(this);
    new MethodChannel(getFlutterView(), statusBarColorChannel).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if(methodCall.method.equals(setStatusBarColorMethod)){
          try {
            HashMap<String, Object> map = (HashMap<String, Object>) methodCall.arguments;
            long colorValue = (long) map.get(statusBarColorValue);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
              getWindow().setStatusBarColor((int)colorValue);
            }
            boolean foregroundWhite = (boolean) map.get(statusBarForegroundWhite);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
              int flags = getWindow().getDecorView().getSystemUiVisibility();
              if(foregroundWhite) {
                flags &= ~(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
              } else {
                flags |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
              }
              getWindow().getDecorView().setSystemUiVisibility(flags);
            }
          } catch (Exception ignore){}
          result.success(null);
        }
      }
    });
  }

  @Override
  protected void onStart(){
    super.onStart();
    registerKeyboardListener();
  }

  @Override
  protected void onResume(){
    super.onResume();
    registerKeyboardListener();
  }

  @Override
  protected void onPause(){
    super.onPause();
    unregisterKeyboardListener();
  }

  @Override
  protected void onStop(){
    super.onStop();
    unregisterKeyboardListener();
  }

  @Override
  protected void onDestroy(){
    super.onDestroy();
    unregisterKeyboardListener();
  }


  private void unregisterKeyboardListener(){
    if(contentView!=null) {
      contentView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
      contentView = null;
    }
  }

  private void registerKeyboardListener(){
    if(contentView==null) {
      contentView = ((ViewGroup) findViewById(android.R.id.content)).getChildAt(0);
      contentView.getViewTreeObserver().addOnGlobalLayoutListener(this);
    }
  }

  private boolean keyboardVisible;
  private EventChannel.EventSink eventSink;
  View contentView;

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    this.eventSink = eventSink;
    if (keyboardVisible) {
      eventSink.success(1);
    }
  }

  @Override
  public void onCancel(Object o) {
    eventSink = null;
  }

  @Override
  public void onGlobalLayout() {
    try{
      Rect r = new Rect();
      contentView.getWindowVisibleDisplayFrame(r);
      boolean currentState = ((double)r.height() / (double)contentView.getRootView().getHeight()) < 0.85;
      if(currentState!=keyboardVisible){
        keyboardVisible = currentState;
        if (eventSink != null) {
          eventSink.success(keyboardVisible ? 1 : 0);
        }
      }
    } catch (Exception ignored){}
  }
}

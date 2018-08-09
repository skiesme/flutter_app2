package com.hdkj.samexapp;

import android.os.Bundle;

import com.xdandroid.hellodaemon.IntentWrapper;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    AlarmPlugin.registerWith(this.registrarFor(AlarmPlugin.key));
  }

  public void onBackPressed() {
    super.onBackPressed();
//    IntentWrapper.onBackPressed(this);
  }
}

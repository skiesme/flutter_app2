package com.hdkj.samexapp;

import com.xdandroid.hellodaemon.DaemonEnv;

import io.flutter.app.FlutterApplication;

public class SMApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        DaemonEnv.initialize(this, AlarmService.class, DaemonEnv.DEFAULT_WAKE_UP_INTERVAL);
        AlarmService.sShouldStopService = false;
//        DaemonEnv.startServiceMayBind(AlarmService.class);
    }
}

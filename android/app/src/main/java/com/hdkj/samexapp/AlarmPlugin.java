package com.hdkj.samexapp;

import android.app.Activity;
import android.content.SharedPreferences;

import com.xdandroid.hellodaemon.DaemonEnv;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class AlarmPlugin implements MethodChannel.MethodCallHandler {

    private final Activity mActivity;

    public final static String key = "com.hdkj.samex/alarm_service";

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel =
                new MethodChannel(registrar.messenger(), key);
        channel.setMethodCallHandler(new AlarmPlugin(registrar.activity()));

    }

    private AlarmPlugin(Activity activity){
        this.mActivity = activity;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        SharedPreferences preferences = AlarmService.getInstance(mActivity.getApplicationContext());

//        android.util.Log.e("SUN", "  method: "+ methodCall.method + "parmas : "+ methodCall.arguments().toString());
        if(methodCall.method.equalsIgnoreCase("start")){

            String token = methodCall.argument("token");
            int numbers = methodCall.argument("workers");
            int interval =  methodCall.argument("interval");
            String url = methodCall.argument("url");

            if(token == null) token = "";

            if(interval < 1 || interval  > 60){
                interval = 3;
            }

            int old = preferences.getInt(AlarmService.TIME, 3);

            if(old != interval){
                AlarmService.stopService();
            }


            preferences.edit().putString(AlarmService.TOKEN, token).apply();
            preferences.edit().putInt(AlarmService.WORKERS, numbers).apply();
            preferences.edit().putInt(AlarmService.TIME, interval).apply();
            preferences.edit().putString(AlarmService.URL, url).apply();

//            mActivity.runOnUiThread(new Runnable() {
//                @Override
//                public void run() {
                    DaemonEnv.startServiceMayBind(AlarmService.class);
//                }
//            });

        } else if(methodCall.method.equalsIgnoreCase("stop")){
            preferences.edit().clear().apply();
            AlarmService.stopService();
        }

    }
}

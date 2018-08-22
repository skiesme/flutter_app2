package com.hdkj.samexapp;


import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.MediaPlayer;
import android.os.IBinder;

import com.xdandroid.hellodaemon.AbsWorkService;

import java.io.IOException;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import io.karn.notify.Notify;
import io.karn.notify.NotifyCreator;
import io.karn.notify.entities.NotifyConfig;
import io.karn.notify.entities.Payload;
import io.reactivex.Observable;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Action;
import io.reactivex.functions.Consumer;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class AlarmService extends AbsWorkService {
    //是否 任务完成, 不再需要服务运行?
    public static boolean sShouldStopService;
    public static Disposable sDisposable;
    public static final String SHARED_PREFERENCES_ALRAM_PULGIN = "alarm_plugin_name";
    public static final String TOKEN = "__token";
    public static final String WORKERS = "__workers";
    public static final String TIME = "__timers";
    public static final String URL = "__URL";
    public static final String NOTIFICATION_ID = "__notification_id";



    public static SharedPreferences mSharedPreferences;

    public  static SharedPreferences getInstance(Context context){
        if(mSharedPreferences == null){
            mSharedPreferences = context.getSharedPreferences(SHARED_PREFERENCES_ALRAM_PULGIN, Context.MODE_PRIVATE);
        }

        return  mSharedPreferences;
    }

    public static void stopService() {
        //我们现在不再需要服务运行了, 将标志位置为 true
        sShouldStopService = true;
        //取消对任务的订阅
        if (sDisposable != null) sDisposable.dispose();
        //取消 Job / Alarm / Subscription
        cancelJobAlarmSub();
    }

    /**
     * 是否 任务完成, 不再需要服务运行?
     * @return 应当停止服务, true; 应当启动服务, false; 无法判断, 什么也不做, null.
     */
    @Override
    public Boolean shouldStopService(Intent intent, int flags, int startId) {
        return sShouldStopService;
    }

    private int show(int  old, final int newOrders){
        Notify n = new  Notify(getBaseContext());

        NotifyConfig c = new NotifyConfig();
        NotifyCreator create = new NotifyCreator(n, c);

        create.content(new Function1<Payload.Content.Default, Unit>() {
            @Override
            public Unit invoke(Payload.Content.Default aDefault) {
                aDefault.setText("收到新的任务单( "+newOrders+" )");
                aDefault.setTitle("通知");
                return null;
            }
        });


        create.meta(new Function1<Payload.Meta, Unit>() {
            @Override
            public Unit invoke(Payload.Meta meta) {
                Intent intent = new Intent(AlarmService.this, MainActivity.class);
                PendingIntent pIntent = PendingIntent.getActivity(AlarmService.this, 1, intent, 0);
                meta.setClickIntent(pIntent);
                return null;
            }
        });

        create.cancel(old);
        int id = create.show();

        MediaPlayer mMediaPlayer= MediaPlayer.create(this, R.raw.notify);
        mMediaPlayer.start();

        return id;

    }

    private void getOrders() {
        SharedPreferences preferences = getInstance(getApplicationContext());
        String url = preferences.getString(URL, "");
        String token = preferences.getString(TOKEN, "");

//        android.util.Log.e("SUN", "开始获取任务数, token="+token+"  url="+url);

        if(url.isEmpty() || token.isEmpty()){
            stopService();
        } else {
            OkHttpClient client = new OkHttpClient();
            Request request = new Request.Builder()
                    .url(url)
                    .addHeader("Authorization", token)
                    .build();

            Response response = null;
            try {
                response = client.newCall(request).execute();
                String result =  response.body().string();

                int old = preferences.getInt(WORKERS, 0);

                if(result.contains("\"orders\":")){
                    String str = result.split("\"orders\":")[1];
                    str = str.substring(0, str.indexOf(","));

                    int new_orders = Integer.parseInt(str);
                    android.util.Log.e("SUN", result+ "\n orders = "+str + "  old_orders =  "+ old);

                    if(new_orders >= 0){
                        preferences.edit().putInt(WORKERS, new_orders).apply();
                    }

                    if(new_orders > old) {
                        int id = preferences.getInt(NOTIFICATION_ID, -1);
                        preferences.edit().putInt(NOTIFICATION_ID, show(id, new_orders)).apply();
                    }

                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }

    @Override
    public void startWork(Intent intent, int flags, int startId) {
        if(isWorkRunning(intent, flags, startId)){
            return;
        }

        try {
            int interval = getInstance(getApplicationContext()).getInt(TIME, 1);
            TimeUnit unit = TimeUnit.MINUTES;
            if(BuildConfig.DEBUG){
                interval = 300;
                unit = TimeUnit.SECONDS;
            }

            android.util.Log.e("SUN", "startWork, unit: "+ unit + " interval="+interval);


            sDisposable = Observable
                    .interval(interval, unit)
                    //取消任务时取消定时唤醒
                    .doOnDispose(new Action() {
                        @Override
                        public void run() throws Exception {
                            cancelJobAlarmSub();
                        }
                    })
                    .subscribe(new Consumer<Long>() {
                        @Override
                        public void accept(Long aLong) throws Exception {
                            android.util.Log.e("SUN", "定时运行 : "+ new Date());
                            getOrders();
                        }
                    });
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    @Override
    public void stopWork(Intent intent, int flags, int startId) {
        stopService();
    }

    /**
     * 任务是否正在运行?
     * @return 任务正在运行, true; 任务当前不在运行, false; 无法判断, 什么也不做, null.
     */
    @Override
    public Boolean isWorkRunning(Intent intent, int flags, int startId) {
        //若还没有取消订阅, 就说明任务仍在运行.
        return sDisposable != null && !sDisposable.isDisposed();
    }

    @Override
    public IBinder onBind(Intent intent, Void v) {
        return null;
    }

    @Override
    public void onServiceKilled(Intent rootIntent) {
        System.out.println("保存数据到磁盘。");
    }
}

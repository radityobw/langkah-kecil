package com.ryocantsleep;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

public class GodotRyoLocalNotifPlugin extends GodotPlugin {

    public GodotRyoLocalNotifPlugin(Godot godot) {
        super(godot);
    }

    @Override
    public String getPluginName() {
        return "RyoLocalNotifPlugin";
    }

    @UsedByGodot
    public void sendNotification(String title, String message) {
        Context context = getGodot().getApplicationContext();
        Intent intent = new Intent(context, LocalNotification.class);
        intent.putExtra("title", title);
        intent.putExtra("message", message);
        context.sendBroadcast(intent);
        Log.i("RyoLocalNotifPlugin", "Notification sent: " + title);
    }

    @UsedByGodot
    public void scheduleNotification(int hour, int minute, String title, String message) {
        Context context = getGodot().getApplicationContext();
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        Intent intent = new Intent(context, LocalNotification.class);
        intent.putExtra("title", title);
        intent.putExtra("message", message);

        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                (int) System.currentTimeMillis(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.set(Calendar.HOUR_OF_DAY, hour);
        calendar.set(Calendar.MINUTE, minute);
        calendar.set(Calendar.SECOND, 0);

        long triggerTime = calendar.getTimeInMillis();
        if (triggerTime < System.currentTimeMillis()) {
            triggerTime += 24 * 60 * 60 * 1000; // kalau sudah lewat, jadwalkan besok
        }

        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent);
        Log.i("RyoLocalNotifPlugin", "Scheduled notification: " + title + " at " + hour + ":" + minute);
    }

    @Override
    public List<String> getPluginMethods() {
        return Arrays.asList("sendNotification", "scheduleNotification");
    }
}

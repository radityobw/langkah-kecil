package android.src.com.ryocantsleep;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Notification;
import android.content.Context;
import android.content.Intent;
import android.content.BroadcastReceiver;
import android.os.Build;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Vibrator;

import androidx.core.app.NotificationCompat;

public class LocalNotification extends BroadcastReceiver {
    public static final String CHANNEL_ID = "ryo_localnotif_channel";

    @Override
    public void onReceive(Context context, Intent intent) {
        String title = intent.getStringExtra("title");
        String message = intent.getStringExtra("message");

        Uri soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.io_boldcat_icon)
                .setContentTitle(title)
                .setContentText(message)
                .setAutoCancel(true)
                .setSound(soundUri)
                .setVibrate(new long[]{500, 500})
                .setPriority(NotificationCompat.PRIORITY_HIGH);

        NotificationManager notificationManager =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Ryo Local Notifications",
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Local notifications with sound and vibration");
            channel.enableVibration(true);
            channel.setSound(soundUri, null);
            notificationManager.createNotificationChannel(channel);
        }

        notificationManager.notify((int) System.currentTimeMillis(), builder.build());
    }
}

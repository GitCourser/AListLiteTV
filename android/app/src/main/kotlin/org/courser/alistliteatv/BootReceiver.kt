package org.courser.alistliteatv

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.courser.alistliteatv.config.AppConfig

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED && AppConfig.isStartAtBootEnabled) {
            context.startService(Intent(context, AListService::class.java))
        }
    }
}

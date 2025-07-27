package org.courser.alistlitetv

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import org.courser.alistlitetv.utils.ToastUtils.toast

class SwitchServerActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (AListService.isRunning) {
            startService(Intent(this, AListService::class.java).apply {
                action = AListService.ACTION_SHUTDOWN
            })
        } else {
            startService(Intent(this, AListService::class.java))
        }

        finish()
    }
}
package org.courser.alistliteatv.config

import com.cioccarellia.ksprefs.KsPrefs
import com.cioccarellia.ksprefs.dynamic
import org.courser.alistliteatv.app

object AppConfig {
    val prefs by lazy { KsPrefs(app, "app") }

    var isSilentJumpAppEnabled by prefs.dynamic("isSilentJumpAppEnabled", fallback = false)

    var isWakeLockEnabled: Boolean by prefs.dynamic("isWakeLockEnabled", fallback = false)
    var isStartAtBootEnabled: Boolean by prefs.dynamic("isStartAtBootEnabled", fallback = false)
    var isAutoCheckUpdateEnabled: Boolean by prefs.dynamic(
        "isAutoCheckUpdateEnabled",
        fallback = false
    )

    var isAutoOpenWebPageEnabled: Boolean by prefs.dynamic(
        "isAutoOpenWebPageEnabled",
        fallback = false
    )

    var themeMode: Int by prefs.dynamic("themeMode", fallback = 1) // 默认主题

    val defaultDataDir by lazy { app.getExternalFilesDir("data")?.absolutePath!! }

    private var mDataDir: String by prefs.dynamic("dataDir", fallback = defaultDataDir)


    var dataDir: String
        get() {
            if (mDataDir.isBlank()) mDataDir = defaultDataDir
            return mDataDir
        }
        set(value) {
            if (value.isBlank()) {
                mDataDir = defaultDataDir
                return
            }

            mDataDir = value
        }

}
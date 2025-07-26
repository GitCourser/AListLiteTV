package org.courser.alistliteatv.bridge

import org.courser.alistliteatv.config.AppConfig
import org.courser.pigeon.GeneratedApi


object AppConfigBridge : GeneratedApi.AppConfig {
    override fun isWakeLockEnabled() = AppConfig.isWakeLockEnabled

    override fun isStartAtBootEnabled() = AppConfig.isStartAtBootEnabled

    override fun isAutoCheckUpdateEnabled() = AppConfig.isAutoCheckUpdateEnabled
    override fun getDataDir() = AppConfig.dataDir

    override fun setDataDir(dir: String) {
        AppConfig.dataDir = dir
    }

    override fun isSilentJumpAppEnabled(): Boolean = AppConfig.isSilentJumpAppEnabled

    override fun setSilentJumpAppEnabled(enabled: Boolean) {
        AppConfig.isSilentJumpAppEnabled = enabled
    }

    override fun setAutoCheckUpdateEnabled(enabled: Boolean) {
        AppConfig.isAutoCheckUpdateEnabled = enabled
    }

    override fun setStartAtBootEnabled(enabled: Boolean) {
        AppConfig.isStartAtBootEnabled = enabled
    }

    override fun setWakeLockEnabled(enabled: Boolean) {
        AppConfig.isWakeLockEnabled = enabled
    }

    override fun getThemeMode(): Long = AppConfig.themeMode.toLong()

    override fun setThemeMode(mode: Long) {
        AppConfig.themeMode = mode.toInt()
    }
}
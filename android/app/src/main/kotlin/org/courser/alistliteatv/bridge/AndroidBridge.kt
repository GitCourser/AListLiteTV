package org.courser.alistliteatv.bridge

import android.content.Context
import android.content.Intent
import android.os.Build
import org.courser.alistliteatv.AListService
import org.courser.alistliteatv.BuildConfig
import org.courser.alistliteatv.R
import org.courser.alistliteatv.SwitchServerActivity
import org.courser.alistliteatv.model.alist.AList
import org.courser.alistliteatv.utils.MyTools
import org.courser.alistliteatv.utils.ToastUtils.longToast
import org.courser.alistliteatv.utils.ToastUtils.toast
import org.courser.pigeon.GeneratedApi

class AndroidBridge(private val context: Context) : GeneratedApi.Android {
    override fun startService() {
        context.startService(Intent(context, AListService::class.java))
    }

    override fun setAdminPwd(pwd: String) {
        AList.setAdminPassword(pwd)
    }

    override fun getAListHttpPort(): Long {
        return AList.getHttpPort().toLong()
    }

    override fun setAListHttpPort(port: Long) {
        AList.setHttpPort(port.toInt())
    }

    override fun getAListDelayedStart(): Long {
        return AList.getDelayedStart().toLong()
    }

    override fun setAListDelayedStart(seconds: Long) {
        AList.setDelayedStart(seconds.toInt())
    }

    override fun isRunning() = AListService.isRunning


    override fun getAListVersion() = BuildConfig.ALIST_VERSION

    override fun getServerAddress(): String {
        return try {
            // 调用 alist-lib 中的 GetOutboundIPString 函数
            alistlib.Alistlib.getOutboundIPString()
        } catch (e: Exception) {
            // 如果调用失败，返回默认值
            "127.0.0.1"
        }
    }
}
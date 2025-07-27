package org.courser.alistlitetv.bridge

import android.content.Context
import android.content.Intent
import android.os.Build
import org.courser.alistlitetv.AListService
import org.courser.alistlitetv.BuildConfig
import org.courser.alistlitetv.R
import org.courser.alistlitetv.SwitchServerActivity
import org.courser.alistlitetv.model.alist.AList
import org.courser.alistlitetv.utils.MyTools
import org.courser.alistlitetv.utils.ToastUtils.longToast
import org.courser.alistlitetv.utils.ToastUtils.toast
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
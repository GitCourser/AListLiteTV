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
    override fun addShortcut() {
        MyTools.addShortcut(
            context,
            context.getString(R.string.app_switch),
            "alist_flutter_switch",
            R.drawable.alist_switch,
            Intent(context, SwitchServerActivity::class.java)
        )
    }

    override fun startService() {
        context.startService(Intent(context, AListService::class.java))
    }

    override fun setAdminPwd(pwd: String) {
        AList.setAdminPassword(pwd)
    }

    override fun getAListHttpPort(): Long {
        return AList.getHttpPort().toLong()
    }

    override fun isRunning() = AListService.isRunning


    override fun getAListVersion() = BuildConfig.ALIST_VERSION
}
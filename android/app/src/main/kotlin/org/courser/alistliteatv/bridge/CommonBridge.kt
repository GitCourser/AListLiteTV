package org.courser.alistliteatv.bridge

import android.content.Context
import android.content.Intent
import android.os.Build
import org.courser.alistliteatv.BuildConfig
import org.courser.alistliteatv.utils.ToastUtils.longToast
import org.courser.alistliteatv.utils.ToastUtils.toast
import org.courser.pigeon.GeneratedApi

class CommonBridge(private val context: Context) : GeneratedApi.NativeCommon {
    override fun startActivityFromUri(intentUri: String): Boolean {
        val intent = Intent.parseUri(intentUri, Intent.URI_INTENT_SCHEME)
        return if (intent.resolveActivity(context.packageManager) != null){
            context.startActivity(intent)
            true
        }else{
            false
        }
    }

    override fun getDeviceSdkInt(): Long {
        return Build.VERSION.SDK_INT.toLong()
    }


    override fun getDeviceCPUABI(): String {
        return Build.SUPPORTED_ABIS[0]
    }

    override fun getVersionName() = BuildConfig.VERSION_NAME
    override fun getVersionCode() = BuildConfig.VERSION_CODE.toLong()


    override fun toast(msg: String) {
        context.toast(msg)
    }

    override fun longToast(msg: String) {
        context.longToast(msg)
    }
}
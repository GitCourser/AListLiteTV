package org.courser.utils

object NativeLib {
    external fun getLocalIp(): String

    init {
        System.loadLibrary("utils")
    }

}
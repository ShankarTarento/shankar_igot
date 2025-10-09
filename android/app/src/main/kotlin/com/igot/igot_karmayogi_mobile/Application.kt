package com.igot.igot_karmayogi_mobile

import android.util.Log
import com.netcore.android.Smartech
import com.netcore.android.smartechpush.SmartPush
import com.netcore.android.smartechpush.notification.SMTNotificationOptions
import com.netcore.smartech_appinbox.SmartechAppinboxPlugin
import com.netcore.smartech_base.SmartechBasePlugin
import com.netcore.smartech_push.SmartechPushPlugin
import io.flutter.app.FlutterApplication
import java.lang.ref.WeakReference

class Application: FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        // Initialize Smartech Sdk
        Smartech.getInstance(WeakReference(applicationContext)).initializeSdk(this)
        // Add the below line for debugging logs
        Smartech.getInstance(WeakReference(applicationContext)).setDebugLevel(9)
        // Add the below line to track app install and update by smartech
        Smartech.getInstance(WeakReference(applicationContext)).trackAppInstallUpdateBySmartech()

        // Initialize Flutter Smartech Base Plugin
        SmartechBasePlugin.initializePlugin(this)

        // Initialize Flutter Smartech Push Plugin
        SmartechPushPlugin.initializePlugin(this)

        SmartechAppinboxPlugin.initializePlugin(this)

        val options = SMTNotificationOptions(this)
        options.brandLogo = "ic_launcher"//e.g.logo is sample name for brand logo
        options.largeIcon = "ic_launcher"//e.g.ic_notification is sample name for large icon
        options.smallIcon = "ic_launcher"//e.g.ic_action_play is sample name for icon
        options.smallIconTransparent = "ic_launcher"//e.g.ic_action_play is sample name for transparent small icon
        options.transparentIconBgColor = "#88568C"
        options.placeHolderIcon = "ic_launcher"//e.g.ic_notification is sample name for placeholder icon
        SmartPush.getInstance(WeakReference(applicationContext)).setNotificationOptions(options)
    }

    override fun onTerminate() {
        super.onTerminate()
        Log.d("onTerminate", "onTerminate")
    }
}
package com.igot.karmayogibharat

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.netcore.smartech_base.SmartechDeeplinkReceivers


class MainActivity: FlutterActivity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        SmartechDeeplinkReceivers().onReceive(this, intent)
    }
}

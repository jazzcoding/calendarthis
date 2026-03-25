package com.calendarthis.calendar_this

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.calendarthis/intent"
    private var sharedText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialText" -> {
                    result.success(sharedText)
                    sharedText = null
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        val action = intent.action
        val type = intent.type

        if (Intent.ACTION_SEND == action && type?.startsWith("text/") == true) {
            // Handle text being sent from other apps (Share)
            intent.getStringExtra(Intent.EXTRA_TEXT)?.let { text ->
                sharedText = text
                sendTextToFlutter(text)
            }
        } else if (Intent.ACTION_PROCESS_TEXT == action && type == "text/plain") {
            // Handle text being processed from context menu
            intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)?.let { text ->
                sharedText = text
                sendTextToFlutter(text)
            }
        }
    }

    private fun sendTextToFlutter(text: String) {
        if (flutterEngine != null) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("receivedText", text)
        } else {
            // Save for later when Flutter engine is ready
            sharedText = text
        }
    }
}

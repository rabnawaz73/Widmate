package com.example.widmate

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "background_download"
    private val eventChannel = "background_download_events"
    private lateinit var backgroundService: BackgroundDownloadService
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize the service immediately
        initializeBackgroundService()

        // Initialize method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            // Method calls can be handled here if needed in the future
            result.notImplemented()
        }

        // Initialize event channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    backgroundService.initializeMethodChannel(
                        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel),
                        events!!
                    )
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    private fun initializeBackgroundService() {
        backgroundService = BackgroundDownloadService()
        val serviceIntent = Intent(this, BackgroundDownloadService::class.java)
        startForegroundService(serviceIntent)
    }
}

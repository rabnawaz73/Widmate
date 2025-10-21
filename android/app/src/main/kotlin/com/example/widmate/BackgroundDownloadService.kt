package com.example.widmate

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.*
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.ConcurrentHashMap

class BackgroundDownloadService : Service() {
    private val binder = LocalBinder()
    private val channel = "background_download"
    private val eventChannel = "background_download_events"
    
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventSink: EventChannel.EventSink
    private lateinit var notificationManager: NotificationManagerCompat
    private lateinit var wakeLock: PowerManager.WakeLock
    
    private val activeDownloads = ConcurrentHashMap<String, DownloadTask>()
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "download_channel"
        private const val CHANNEL_NAME = "Download Service"
        private const val CHANNEL_DESCRIPTION = "Background download notifications"
    }
    
    inner class LocalBinder : Binder() {
        fun getService(): BackgroundDownloadService = this@BackgroundDownloadService
    }
    
    override fun onCreate() {
        super.onCreate()
        
        // Initialize notification channel
        createNotificationChannel()
        
        // Initialize wake lock to keep CPU awake during downloads
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "WidMate::BackgroundDownload"
        )
        
        notificationManager = NotificationManagerCompat.from(this)
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, createNotification("Download service running"))
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder = binder
    
    fun initializeMethodChannel(methodChannel: MethodChannel, eventSink: EventChannel.EventSink) {
        this.methodChannel = methodChannel
        this.eventSink = eventSink
        
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    result.success(null)
                }
                "startDownload" -> {
                    val args = call.arguments as Map<String, Any>
                    startDownload(args)
                    result.success(null)
                }
                "pauseDownload" -> {
                    val id = call.arguments as Map<String, Any>
                    pauseDownload(id["id"] as String)
                    result.success(null)
                }
                "resumeDownload" -> {
                    val id = call.arguments as Map<String, Any>
                    resumeDownload(id["id"] as String)
                    result.success(null)
                }
                "cancelDownload" -> {
                    val id = call.arguments as Map<String, Any>
                    cancelDownload(id["id"] as String)
                    result.success(null)
                }
                "getActiveDownloads" -> {
                    result.success(getActiveDownloadsList())
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = CHANNEL_DESCRIPTION
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(content: String): Notification {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("WidMate Downloads")
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
    
    private fun startDownload(args: Map<String, Any>) {
        val id = args["id"] as String
        val url = args["url"] as String
        val title = args["title"] as String
        val fileName = args["fileName"] as String
        val filePath = args["filePath"] as String
        val platform = args["platform"] as String
        
        val downloadTask = DownloadTask(
            id = id,
            url = url,
            title = title,
            fileName = fileName,
            filePath = filePath,
            platform = platform,
            onProgress = { progress, downloadedBytes, totalBytes, speed, eta ->
                sendEvent("progress", id, mapOf(
                    "progress" to progress,
                    "downloadedBytes" to downloadedBytes,
                    "totalBytes" to totalBytes,
                    "speed" to speed,
                    "eta" to eta
                ))
                updateNotification("Downloading: $title")
            },
            onCompleted = { finalPath ->
                sendEvent("completed", id, mapOf("filePath" to finalPath))
                updateNotification("Download completed: $title")
            },
            onFailed = { error ->
                sendEvent("failed", id, mapOf("error" to error))
                updateNotification("Download failed: $title")
            }
        )
        
        activeDownloads[id] = downloadTask
        serviceScope.launch {
            downloadTask.start()
        }
    }
    
    private fun pauseDownload(id: String) {
        activeDownloads[id]?.pause()
        sendEvent("paused", id, emptyMap())
    }
    
    private fun resumeDownload(id: String) {
        activeDownloads[id]?.resume()
        sendEvent("resumed", id, emptyMap())
    }
    
    private fun cancelDownload(id: String) {
        activeDownloads[id]?.cancel()
        activeDownloads.remove(id)
    }
    
    private fun getActiveDownloadsList(): List<Map<String, Any>> {
        return activeDownloads.values.map { task ->
            mapOf<String, Any>(
                "id" to task.id,
                "url" to task.url,
                "title" to task.title,
                "fileName" to task.fileName,
                "filePath" to task.filePath,
                "totalBytes" to task.totalBytes,
                "downloadedBytes" to task.downloadedBytes,
                "progress" to task.progress,
                "speed" to task.speed,
                "eta" to task.eta,
                "status" to task.status,
                "platform" to task.platform,
                "createdAt" to task.createdAt.toString(),
                "completedAt" to (task.completedAt?.toString() ?: ""),
                "thumbnailUrl" to ""
            )
        }.toList()
    }
    
    private fun sendEvent(type: String, id: String, data: Map<String, Any>) {
        val eventData = mapOf(
            "type" to type,
            "id" to id
        ) + data
        
        try {
            eventSink.success(eventData)
        } catch (e: Exception) {
            // Handle event sink error
        }
    }
    
    private fun updateNotification(content: String) {
        val notification = createNotification(content)
        notificationManager.notify(NOTIFICATION_ID, notification)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        wakeLock.release()
        serviceScope.cancel()
        activeDownloads.clear()
    }
}

class DownloadTask(
    val id: String,
    val url: String,
    val title: String,
    val fileName: String,
    val filePath: String,
    val platform: String,
    private val onProgress: (Double, Long, Long, Int, Int) -> Unit,
    private val onCompleted: (String) -> Unit,
    private val onFailed: (String) -> Unit
) {
    var totalBytes: Long = 0
    var downloadedBytes: Long = 0
    var progress: Double = 0.0
    var speed: Int = 0
    var eta: Int = 0
    var status: String = "queued"
    val createdAt: Long = System.currentTimeMillis()
    var completedAt: Long? = null
    
    private var isPaused = false
    private var isCancelled = false
    private var downloadJob: Job? = null
    
    suspend fun start() {
        if (isCancelled) return
        
        status = "downloading"
        downloadJob = CoroutineScope(Dispatchers.IO).launch {
            try {
                val connection = URL(url).openConnection() as HttpURLConnection
                connection.requestMethod = "GET"
                connection.connectTimeout = 30000
                connection.readTimeout = 30000
                
                totalBytes = connection.contentLength.toLong()
                
                val inputStream = connection.inputStream
                val outputFile = File(filePath)
                outputFile.parentFile?.mkdirs()
                
                val outputStream = FileOutputStream(outputFile)
                val buffer = ByteArray(8192)
                var bytesRead: Int
                val startTime = System.currentTimeMillis()
                
                while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                    if (isCancelled) break
                    
                    while (isPaused && !isCancelled) {
                        delay(100)
                    }
                    
                    if (isCancelled) break
                    
                    outputStream.write(buffer, 0, bytesRead)
                    downloadedBytes += bytesRead
                    progress = if (totalBytes > 0) downloadedBytes.toDouble() / totalBytes else 0.0
                    
                    val currentTime = System.currentTimeMillis()
                    val elapsedTime = (currentTime - startTime) / 1000.0
                    speed = if (elapsedTime > 0) (downloadedBytes / elapsedTime).toInt() else 0
                    eta = if (speed > 0 && totalBytes > downloadedBytes) {
                        ((totalBytes - downloadedBytes) / speed).toInt()
                    } else 0
                    
                    onProgress(progress, downloadedBytes, totalBytes, speed, eta)
                }
                
                inputStream.close()
                outputStream.close()
                connection.disconnect()
                
                if (!isCancelled) {
                    status = "completed"
                    completedAt = System.currentTimeMillis()
                    onCompleted(filePath)
                }
                
            } catch (e: Exception) {
                if (!isCancelled) {
                    status = "failed"
                    onFailed(e.message ?: "Unknown error")
                }
            }
        }
    }
    
    fun pause() {
        isPaused = true
        status = "paused"
    }
    
    fun resume() {
        isPaused = false
        status = "downloading"
    }
    
    fun cancel() {
        isCancelled = true
        downloadJob?.cancel()
        status = "canceled"
    }
}

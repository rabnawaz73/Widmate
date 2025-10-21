import Foundation
import Flutter
import UIKit
import BackgroundTasks

@available(iOS 13.0, *)
class BackgroundDownloadService: NSObject {
    private var methodChannel: FlutterMethodChannel?
    private var eventSink: FlutterEventSink?
    private var activeDownloads: [String: DownloadTask] = [:]
    
    func initializeMethodChannel(methodChannel: FlutterMethodChannel, eventSink: FlutterEventSink?) {
        self.methodChannel = methodChannel
        self.eventSink = eventSink
        
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "initialize":
                self?.initialize()
                result(nil)
            case "startDownload":
                if let args = call.arguments as? [String: Any] {
                    self?.startDownload(args: args)
                }
                result(nil)
            case "pauseDownload":
                if let args = call.arguments as? [String: Any],
                   let id = args["id"] as? String {
                    self?.pauseDownload(id: id)
                }
                result(nil)
            case "resumeDownload":
                if let args = call.arguments as? [String: Any],
                   let id = args["id"] as? String {
                    self?.resumeDownload(id: id)
                }
                result(nil)
            case "cancelDownload":
                if let args = call.arguments as? [String: Any],
                   let id = args["id"] as? String {
                    self?.cancelDownload(id: id)
                }
                result(nil)
            case "getActiveDownloads":
                result(self?.getActiveDownloadsList())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func initialize() {
        // Register background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.widmate.download", using: nil) { task in
            self.handleBackgroundDownload(task: task as! BGAppRefreshTask)
        }
        
        // Schedule background app refresh
        scheduleBackgroundAppRefresh()
    }
    
    private func scheduleBackgroundAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.example.widmate.download")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleBackgroundDownload(task: BGAppRefreshTask) {
        // Schedule the next background refresh
        scheduleBackgroundAppRefresh()
        
        // Continue any active downloads
        for downloadTask in activeDownloads.values {
            if downloadTask.status == "downloading" {
                downloadTask.continueDownload()
            }
        }
        
        task.setTaskCompleted(success: true)
    }
    
    private func startDownload(args: [String: Any]) {
        guard let id = args["id"] as? String,
              let url = args["url"] as? String,
              let title = args["title"] as? String,
              let fileName = args["fileName"] as? String,
              let filePath = args["filePath"] as? String,
              let platform = args["platform"] as? String else {
            return
        }
        
        let downloadTask = DownloadTask(
            id: id,
            url: url,
            title: title,
            fileName: fileName,
            filePath: filePath,
            platform: platform,
            onProgress: { [weak self] progress, downloadedBytes, totalBytes, speed, eta in
                self?.sendEvent(type: "progress", id: id, data: [
                    "progress": progress,
                    "downloadedBytes": downloadedBytes,
                    "totalBytes": totalBytes,
                    "speed": speed,
                    "eta": eta
                ])
            },
            onCompleted: { [weak self] filePath in
                self?.sendEvent(type: "completed", id: id, data: ["filePath": filePath])
                self?.activeDownloads.removeValue(forKey: id)
            },
            onFailed: { [weak self] error in
                self?.sendEvent(type: "failed", id: id, data: ["error": error])
                self?.activeDownloads.removeValue(forKey: id)
            }
        )
        
        activeDownloads[id] = downloadTask
        downloadTask.start()
    }
    
    private func pauseDownload(id: String) {
        activeDownloads[id]?.pause()
        sendEvent(type: "paused", id: id, data: [:])
    }
    
    private func resumeDownload(id: String) {
        activeDownloads[id]?.resume()
        sendEvent(type: "resumed", id: id, data: [:])
    }
    
    private func cancelDownload(id: String) {
        activeDownloads[id]?.cancel()
        activeDownloads.removeValue(forKey: id)
    }
    
    private func getActiveDownloadsList() -> [[String: Any]] {
        return activeDownloads.values.map { task in
            [
                "id": task.id,
                "url": task.url,
                "title": task.title,
                "fileName": task.fileName,
                "filePath": task.filePath,
                "totalBytes": task.totalBytes,
                "downloadedBytes": task.downloadedBytes,
                "progress": task.progress,
                "speed": task.speed,
                "eta": task.eta,
                "status": task.status,
                "platform": task.platform,
                "createdAt": ISO8601DateFormatter().string(from: task.createdAt),
                "completedAt": task.completedAt?.iso8601String,
                "thumbnailUrl": NSNull()
            ]
        }
    }
    
    private func sendEvent(type: String, id: String, data: [String: Any]) {
        var eventData: [String: Any] = ["type": type, "id": id]
        eventData.merge(data) { (_, new) in new }
        
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(eventData)
        }
    }
}

class DownloadTask {
    let id: String
    let url: String
    let title: String
    let fileName: String
    let filePath: String
    let platform: String
    
    var totalBytes: Int64 = 0
    var downloadedBytes: Int64 = 0
    var progress: Double = 0.0
    var speed: Int = 0
    var eta: Int = 0
    var status: String = "queued"
    let createdAt: Date = Date()
    var completedAt: Date?
    
    private var isPaused = false
    private var isCancelled = false
    private var downloadTask: URLSessionDownloadTask?
    private let onProgress: (Double, Int64, Int64, Int, Int) -> Void
    private let onCompleted: (String) -> Void
    private let onFailed: (String) -> Void
    
    init(id: String, url: String, title: String, fileName: String, filePath: String, platform: String,
         onProgress: @escaping (Double, Int64, Int64, Int, Int) -> Void,
         onCompleted: @escaping (String) -> Void,
         onFailed: @escaping (String) -> Void) {
        self.id = id
        self.url = url
        self.title = title
        self.fileName = fileName
        self.filePath = filePath
        self.platform = platform
        self.onProgress = onProgress
        self.onCompleted = onCompleted
        self.onFailed = onFailed
    }
    
    func start() {
        guard let url = URL(string: self.url) else {
            onFailed("Invalid URL")
            return
        }
        
        status = "downloading"
        
        let session = URLSession(configuration: .default, delegate: DownloadDelegate(task: self), delegateQueue: nil)
        downloadTask = session.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    func pause() {
        isPaused = true
        status = "paused"
        downloadTask?.suspend()
    }
    
    func resume() {
        isPaused = false
        status = "downloading"
        downloadTask?.resume()
    }
    
    func cancel() {
        isCancelled = true
        status = "canceled"
        downloadTask?.cancel()
    }
    
    func continueDownload() {
        if status == "paused" {
            resume()
        }
    }
    
    func updateProgress(downloadedBytes: Int64, totalBytes: Int64) {
        self.downloadedBytes = downloadedBytes
        self.totalBytes = totalBytes
        self.progress = totalBytes > 0 ? Double(downloadedBytes) / Double(totalBytes) : 0.0
        
        // Calculate speed and ETA (simplified)
        self.speed = 0 // Would need to track time for accurate speed
        self.eta = 0 // Would need to track time for accurate ETA
        
        onProgress(progress, downloadedBytes, totalBytes, speed, eta)
    }
    
    func complete(filePath: String) {
        status = "completed"
        completedAt = Date()
        onCompleted(filePath)
    }
    
    func fail(error: String) {
        status = "failed"
        onFailed(error)
    }
}

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    private let task: DownloadTask
    
    init(task: DownloadTask) {
        self.task = task
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(task.fileName)
        
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            task.complete(filePath: destinationURL.path)
        } catch {
            task.fail(error: error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        task.updateProgress(downloadedBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            task.fail(error: error.localizedDescription)
        }
    }
}

extension Date {
    var iso8601String: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

import Flutter
import UIKit
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var backgroundService: BackgroundDownloadService?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Initialize background download service
    if #available(iOS 13.0, *) {
      backgroundService = BackgroundDownloadService()
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    
    // Request background time for downloads
    if #available(iOS 13.0, *) {
      var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
      
      backgroundTaskID = application.beginBackgroundTask(withName: "DownloadTask") {
        application.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
      }
      
      // Continue downloads in background
      DispatchQueue.global(qos: .background).async {
        // Background work here
        DispatchQueue.main.async {
          application.endBackgroundTask(backgroundTaskID)
          backgroundTaskID = .invalid
        }
      }
    }
  }
}

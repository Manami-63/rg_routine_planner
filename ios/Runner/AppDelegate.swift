import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    OpenedFiles.shared.attach(engineBridge.applicationRegistrar.messenger())
  }
}

/// Tells Dart about routine files opened from other apps. A file can arrive
/// before Dart is ready, so it waits until Dart asks for it.
final class OpenedFiles {
  static let shared = OpenedFiles()

  private var channel: FlutterMethodChannel?
  private var pendingPath: String?

  func attach(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "rg_routine_planner/opened_files",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "takePending" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self?.pendingPath)
      self?.pendingPath = nil
    }
    self.channel = channel
  }

  func opened(_ url: URL) {
    pendingPath = url.path
    channel?.invokeMethod("fileOpened", arguments: nil)
  }
}

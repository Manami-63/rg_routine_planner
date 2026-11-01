import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  // A routine file that launched the app.
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    if let url = connectionOptions.urlContexts.first?.url {
      OpenedFiles.shared.opened(url)
    }
  }

  // A routine file opened while the app was running.
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
    if let url = URLContexts.first?.url {
      OpenedFiles.shared.opened(url)
    }
  }
}

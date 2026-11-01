package app.saitoworks.rgroutineplanner

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    // A file can arrive before Dart is ready, so it waits until Dart asks.
    private var pendingPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rg_routine_planner/opened_files",
        ).also {
            it.setMethodCallHandler { call, result ->
                if (call.method == "takePending") {
                    result.success(pendingPath)
                    pendingPath = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // When restored, the same intent comes back: it was already imported.
        if (savedInstanceState == null) copyOpenedFile(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        copyOpenedFile(intent)
    }

    // Other apps give a content:// link, which Dart cannot read.
    private fun copyOpenedFile(intent: Intent) {
        if (intent.action != Intent.ACTION_VIEW) return
        val uri = intent.data ?: return
        val file = File(cacheDir, "opened-${System.nanoTime()}.rgroutine")
        thread {
            try {
                contentResolver.openInputStream(uri)!!.use { input ->
                    file.outputStream().use { input.copyTo(it) }
                }
                runOnUiThread {
                    pendingPath = file.path
                    channel?.invokeMethod("fileOpened", null)
                }
            } catch (_: Exception) {
                file.delete()
            }
        }
    }
}

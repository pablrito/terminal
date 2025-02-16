import android.content.Context
import android.telecom.TelecomManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "call_control"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "hangUpCall") {
                val success = hangUpCall()
                result.success(success)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun hangUpCall(): Boolean {
        val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        return telecomManager?.endCall() ?: false
    }
}

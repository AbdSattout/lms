package app.lms

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val externalUrlChannel = "app.lms/external_url"
    private var externalUrlMethodChannel: MethodChannel? = null
    private var pendingBillingDeepLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        externalUrlMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            externalUrlChannel
        )

        externalUrlMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "openUrl" -> openUrl(call.argument("url"), result)
                "takeInitialBillingDeepLink" -> {
                    result.success(pendingBillingDeepLink)
                    pendingBillingDeepLink = null
                }
                "clearInitialBillingDeepLink" -> {
                    pendingBillingDeepLink = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        dispatchBillingDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        dispatchBillingDeepLink(intent)
    }

    private fun openUrl(url: String?, result: MethodChannel.Result) {
        if (url.isNullOrBlank()) {
            result.error("invalid_url", "URL is empty", null)
            return
        }

        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                addCategory(Intent.CATEGORY_BROWSABLE)
            }
            startActivity(intent)
            result.success(true)
        } catch (error: ActivityNotFoundException) {
            result.error("activity_not_found", "No app can open this URL", null)
        } catch (error: Exception) {
            result.error("open_url_failed", error.message, null)
        }
    }

    private fun dispatchBillingDeepLink(intent: Intent?) {
        val url = intent?.dataString ?: return
        val uri = Uri.parse(url)
        if (uri.scheme != "lms" || uri.host != "billing") return

        pendingBillingDeepLink = url
        externalUrlMethodChannel?.invokeMethod(
            "billingDeepLink",
            mapOf("url" to url)
        )
    }
}

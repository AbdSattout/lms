package app.lms

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val externalUrlChannel = "app.lms/external_url"
    private val foregroundNotificationsChannel = "app.lms/foreground_notifications"
    private val foregroundNotificationChannelId = "lms_foreground_notifications"
    private var externalUrlMethodChannel: MethodChannel? = null
    private var foregroundNotificationsMethodChannel: MethodChannel? = null
    private var pendingBillingDeepLink: String? = null
    private var pendingInviteDeepLink: String? = null

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
                "takeInitialInviteDeepLink" -> {
                    result.success(pendingInviteDeepLink)
                    pendingInviteDeepLink = null
                }
                "clearInitialInviteDeepLink" -> {
                    pendingInviteDeepLink = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        foregroundNotificationsMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            foregroundNotificationsChannel
        )

        foregroundNotificationsMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "showNotification" -> showForegroundNotification(
                    call.argument("title"),
                    call.argument("body"),
                    call.argument("notificationId"),
                    result
                )
                else -> result.notImplemented()
            }
        }

        dispatchAppDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        dispatchAppDeepLink(intent)
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

    private fun showForegroundNotification(
        title: String?,
        body: String?,
        notificationId: Int?,
        result: MethodChannel.Result
    ) {
        if (title.isNullOrBlank() && body.isNullOrBlank()) {
            result.success(false)
            return
        }

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                PackageManager.PERMISSION_GRANTED
        ) {
            result.success(false)
            return
        }

        try {
            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            ensureForegroundNotificationChannel(notificationManager)

            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            val pendingIntent = launchIntent?.let {
                PendingIntent.getActivity(
                    this,
                    0,
                    it,
                    PendingIntent.FLAG_UPDATE_CURRENT or immutablePendingIntentFlag()
                )
            }
            val appLabel = applicationInfo.loadLabel(packageManager)?.toString() ?: "LMS"
            val notificationTitle = title?.takeIf { it.isNotBlank() } ?: appLabel
            val notificationBody = body?.takeIf { it.isNotBlank() } ?: notificationTitle
            val notificationIcon = applicationInfo.icon.takeIf { it != 0 }
                ?: resources.getIdentifier("ic_launcher", "mipmap", packageName)

            @Suppress("DEPRECATION")
            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, foregroundNotificationChannelId)
            } else {
                Notification.Builder(this)
            }

            @Suppress("DEPRECATION")
            builder
                .setSmallIcon(notificationIcon)
                .setContentTitle(notificationTitle)
                .setContentText(notificationBody)
                .setStyle(Notification.BigTextStyle().bigText(notificationBody))
                .setAutoCancel(true)
                .setShowWhen(true)
                .setWhen(System.currentTimeMillis())

            if (pendingIntent != null) {
                builder.setContentIntent(pendingIntent)
            }

            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                @Suppress("DEPRECATION")
                builder.setPriority(Notification.PRIORITY_HIGH)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                builder.setCategory(Notification.CATEGORY_MESSAGE)
            }

            notificationManager.notify(
                notificationId ?: nextNotificationId(),
                builder.build()
            )
            result.success(true)
        } catch (error: Exception) {
            result.error("notification_failed", error.message, null)
        }
    }

    private fun ensureForegroundNotificationChannel(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val existingChannel = notificationManager.getNotificationChannel(
            foregroundNotificationChannelId
        )
        if (existingChannel != null) return

        val channel = NotificationChannel(
            foregroundNotificationChannelId,
            "LMS notifications",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Notifications shown while LMS is open"
            enableVibration(true)
        }

        notificationManager.createNotificationChannel(channel)
    }

    private fun immutablePendingIntentFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
    }

    private fun nextNotificationId(): Int {
        return (System.currentTimeMillis() % Int.MAX_VALUE).toInt()
    }

    private fun dispatchAppDeepLink(intent: Intent?) {
        dispatchBillingDeepLink(intent)
        dispatchInviteDeepLink(intent)
    }

    private fun dispatchBillingDeepLink(intent: Intent?) {
        val url = intent?.dataString ?: return
        val uri = Uri.parse(url)
        val billingDeepLink = when {
            uri.scheme == "lms" && uri.host == "billing" -> url
            uri.scheme == "https" &&
                uri.host == "lmscenter.vercel.app" &&
                uri.pathSegments.size >= 3 &&
                uri.pathSegments[0] == "mobile" &&
                uri.pathSegments[1] == "billing" -> {
                "lms://billing/${uri.pathSegments[2]}"
            }
            else -> return
        }

        pendingBillingDeepLink = billingDeepLink
        externalUrlMethodChannel?.invokeMethod(
            "billingDeepLink",
            mapOf("url" to billingDeepLink)
        )
    }

    private fun dispatchInviteDeepLink(intent: Intent?) {
        val url = intent?.dataString ?: return
        val uri = Uri.parse(url)
        val token = when {
            uri.scheme == "lms" && uri.host == "invite" -> {
                uri.pathSegments.firstOrNull() ?: uri.getQueryParameter("token")
            }
            uri.scheme == "https" &&
                uri.host == "lmscenter.vercel.app" &&
                uri.pathSegments.size >= 2 &&
                uri.pathSegments[0] == "invite" -> uri.pathSegments[1]
            uri.scheme == "https" &&
                uri.host == "lmscenter.vercel.app" &&
                uri.pathSegments.size >= 3 &&
                uri.pathSegments[0] == "mobile" &&
                uri.pathSegments[1] == "invite" -> uri.pathSegments[2]
            else -> return
        }

        if (token.isNullOrBlank()) return

        val inviteDeepLink = Uri.Builder()
            .scheme("lms")
            .authority("invite")
            .appendPath(token)
            .build()
            .toString()

        pendingInviteDeepLink = inviteDeepLink
        externalUrlMethodChannel?.invokeMethod(
            "inviteDeepLink",
            mapOf("url" to inviteDeepLink)
        )
    }
}

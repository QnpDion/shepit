package com.shepit.shepit

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val WIDGET_CHANNEL = "com.shepit.shepit/widget"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "updateWidget") {
                    val preferences = getSharedPreferences(
                        ShepitWidgetProvider.PREFS_NAME,
                        Context.MODE_PRIVATE,
                    )
                    preferences.edit()
                        .putBoolean(
                            ShepitWidgetProvider.KEY_REVEALED,
                            call.argument<Boolean>("revealed") ?: false,
                        )
                        .putString(
                            ShepitWidgetProvider.KEY_KIND,
                            call.argument<String>("kind") ?: getString(R.string.daily_whisper),
                        )
                        .putString(
                            ShepitWidgetProvider.KEY_TEXT,
                            call.argument<String>("text") ?: getString(R.string.widget_hidden_text),
                        )
                        .putString(
                            ShepitWidgetProvider.KEY_HIDDEN_TEXT,
                            call.argument<String>("hiddenText") ?: getString(R.string.widget_hidden_text),
                        )
                        .putString(
                            ShepitWidgetProvider.KEY_ACTION,
                            call.argument<String>("action") ?: getString(R.string.widget_open),
                        )
                        .putString(
                            ShepitWidgetProvider.KEY_DAILY_LABEL,
                            call.argument<String>("dailyLabel") ?: getString(R.string.daily_whisper),
                        )
                        .apply()
                    ShepitWidgetProvider.updateAll(this)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}

package com.shepit.shepit

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class ShepitWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            render(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        const val PREFS_NAME = "shepit_widget"
        const val KEY_REVEALED = "revealed"
        const val KEY_KIND = "kind"
        const val KEY_TEXT = "text"
        const val KEY_HIDDEN_TEXT = "hiddenText"
        const val KEY_ACTION = "action"
        const val KEY_DAILY_LABEL = "dailyLabel"

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, ShepitWidgetProvider::class.java)
            manager.getAppWidgetIds(component).forEach { appWidgetId ->
                render(context, manager, appWidgetId)
            }
        }

        private fun render(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val revealed = preferences.getBoolean(KEY_REVEALED, false)
            val dailyLabel = preferences.getString(
                KEY_DAILY_LABEL,
                context.getString(R.string.daily_whisper),
            ) ?: context.getString(R.string.daily_whisper)
            val kind = preferences.getString(KEY_KIND, dailyLabel) ?: dailyLabel
            val hiddenText = preferences.getString(
                KEY_HIDDEN_TEXT,
                context.getString(R.string.widget_hidden_text),
            ) ?: context.getString(R.string.widget_hidden_text)
            val text = preferences.getString(KEY_TEXT, hiddenText) ?: hiddenText
            val action = preferences.getString(
                KEY_ACTION,
                context.getString(R.string.widget_open),
            ) ?: context.getString(R.string.widget_open)
            val views = RemoteViews(context.packageName, R.layout.shepit_widget)
            views.setTextViewText(
                R.id.widget_kicker,
                if (revealed) kind.uppercase() else dailyLabel.uppercase(),
            )
            views.setTextViewText(R.id.widget_text, text)
            views.setTextViewText(
                R.id.widget_action,
                action,
            )
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

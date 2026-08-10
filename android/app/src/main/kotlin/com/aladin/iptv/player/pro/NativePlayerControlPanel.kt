package com.aladin.iptv.player.pro

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.Gravity
import android.view.ViewGroup
import android.view.Window
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.content.ContextCompat

/** Lightweight, D-pad-first secondary control sheet shared by TV and touch devices. */
internal class NativePlayerControlPanel(private val context: Context) {
    data class Action(val label: String, val invoke: () -> Unit)

    fun show(title: String, actions: List<Action>, onDismiss: () -> Unit) {
        val dialog = Dialog(context)
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        val density = context.resources.displayMetrics.density
        fun dp(value: Int) = (value * density).toInt()

        val root = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(24), dp(20), dp(24))
            setBackgroundColor(Color.rgb(18, 18, 18))
        }
        root.addView(TextView(context).apply {
            text = title
            setTextColor(Color.WHITE)
            textSize = 20f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(dp(12), 0, dp(12), dp(16))
        })

        var first: TextView? = null
        actions.forEach { action ->
            val button = TextView(context).apply {
                text = action.label
                textSize = 17f
                gravity = Gravity.CENTER_VERTICAL
                isClickable = true
                isFocusable = true
                isFocusableInTouchMode = false
                background = ContextCompat.getDrawable(context, R.drawable.player_control_selector)
                setTextColor(ContextCompat.getColorStateList(context, R.color.player_control_text))
                setPadding(dp(18), 0, dp(18), 0)
                setOnClickListener {
                    dialog.dismiss()
                    action.invoke()
                }
            }
            root.addView(button, LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(58)
            ).apply { setMargins(0, dp(4), 0, dp(4)) })
            if (first == null) first = button
        }

        val scroll = ScrollView(context).apply {
            isFillViewport = true
            isFocusable = false
            addView(root, ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ))
        }
        dialog.setContentView(scroll)
        dialog.setOnDismissListener { onDismiss() }
        dialog.window?.apply {
            setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
            setDimAmount(0.45f)
            addFlags(android.view.WindowManager.LayoutParams.FLAG_DIM_BEHIND)
            attributes = attributes.apply { gravity = Gravity.END }
            setLayout(dp(390), ViewGroup.LayoutParams.MATCH_PARENT)
        }
        dialog.show()
        dialog.window?.setLayout(dp(390), ViewGroup.LayoutParams.MATCH_PARENT)
        first?.requestFocus()
    }
}

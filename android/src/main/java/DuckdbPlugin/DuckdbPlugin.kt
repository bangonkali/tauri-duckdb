package DuckdbPlugin

import android.app.Activity
import app.tauri.annotation.Command
import app.tauri.annotation.TauriPlugin
import app.tauri.plugin.JSObject
import app.tauri.plugin.Plugin
import app.tauri.plugin.Invoke

@TauriPlugin
class DuckdbPlugin(private val activity: Activity): Plugin(activity) {
    @Command
    fun ping(invoke: Invoke) {
        val value = invoke.getString("value") ?: ""
        val ret = JSObject()
        ret.put("value", value)
        invoke.resolve(ret)
    }
}

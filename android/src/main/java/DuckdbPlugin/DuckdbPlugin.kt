package DuckdbPlugin

import android.app.Activity
import android.content.Context
import app.tauri.annotation.Command
import app.tauri.annotation.TauriPlugin
import app.tauri.plugin.JSObject
import app.tauri.plugin.Plugin
import app.tauri.plugin.Invoke
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

@TauriPlugin
class DuckdbPlugin(private val activity: Activity): Plugin(activity) {
    private var dbPath: String? = null
    private val mockDatabase = mutableListOf<Map<String, Any>>()

    @Command
    fun ping(invoke: Invoke) {
        val value = invoke.getString("value") ?: ""
        val ret = JSObject()
        ret.put("value", value)
        invoke.resolve(ret)
    }

    @Command
    fun execute(invoke: Invoke) {
        val query = invoke.getString("query") ?: ""
        
        try {
            // Initialize mock database if needed
            if (query.contains("CREATE TABLE", ignoreCase = true)) {
                mockDatabase.clear()
                val ret = JSObject()
                ret.put("success", true)
                ret.put("message", "Table created successfully (mock)")
                ret.put("rowsAffected", 0)
                invoke.resolve(ret)
                return
            }
            
            // Handle INSERT
            if (query.contains("INSERT INTO", ignoreCase = true)) {
                // Parse simple INSERT (mock implementation)
                val values = extractValues(query)
                if (values != null) {
                    mockDatabase.add(values)
                }
                
                val ret = JSObject()
                ret.put("success", true)
                ret.put("message", "Data inserted successfully (mock)")
                ret.put("rowsAffected", 1)
                invoke.resolve(ret)
                return
            }
            
            // Generic success for other commands
            val ret = JSObject()
            ret.put("success", true)
            ret.put("message", "Command executed successfully (mock)")
            ret.put("rowsAffected", 0)
            invoke.resolve(ret)
            
        } catch (e: Exception) {
            val ret = JSObject()
            ret.put("success", false)
            ret.put("message", "Error: ${e.message}")
            ret.put("rowsAffected", 0)
            invoke.resolve(ret)
        }
    }

    @Command
    fun query(invoke: Invoke) {
        val query = invoke.getString("query") ?: ""
        
        try {
            // Return mock data for SELECT queries
            if (query.contains("SELECT", ignoreCase = true)) {
                val jsonArray = JSONArray()
                
                // If we have mock data, return it
                if (mockDatabase.isNotEmpty()) {
                    for (row in mockDatabase) {
                        val jsonObj = JSONObject()
                        for ((key, value) in row) {
                            jsonObj.put(key, value)
                        }
                        jsonArray.put(jsonObj)
                    }
                } else {
                    // Return sample data for demonstration
                    val sample1 = JSONObject()
                    sample1.put("id", 1)
                    sample1.put("name", "Sample User 1")
                    sample1.put("email", "user1@example.com")
                    jsonArray.put(sample1)
                    
                    val sample2 = JSONObject()
                    sample2.put("id", 2)
                    sample2.put("name", "Sample User 2")
                    sample2.put("email", "user2@example.com")
                    jsonArray.put(sample2)
                }
                
                val ret = JSObject()
                ret.put("success", true)
                ret.put("data", jsonArray)
                ret.put("message", "Query executed successfully (mock)")
                invoke.resolve(ret)
            } else {
                val ret = JSObject()
                ret.put("success", true)
                ret.put("data", JSONArray())
                ret.put("message", "No data returned")
                invoke.resolve(ret)
            }
            
        } catch (e: Exception) {
            val ret = JSObject()
            ret.put("success", false)
            ret.put("data", JSONArray())
            ret.put("message", "Error: ${e.message}")
            invoke.resolve(ret)
        }
    }
    
    private fun extractValues(query: String): Map<String, Any>? {
        // Very simple parser for demo - in production use proper SQL parsing
        try {
            val valuesStart = query.indexOf("VALUES", ignoreCase = true)
            if (valuesStart == -1) return null
            
            val valuesStr = query.substring(valuesStart + 6).trim()
            val values = valuesStr.removeSurrounding("(", ")").split(",")
            
            return mapOf(
                "id" to (mockDatabase.size + 1),
                "name" to values.getOrNull(1)?.trim()?.removeSurrounding("'") ?: "Unknown",
                "email" to values.getOrNull(2)?.trim()?.removeSurrounding("'") ?: "unknown@example.com"
            )
        } catch (e: Exception) {
            return null
        }
    }
}

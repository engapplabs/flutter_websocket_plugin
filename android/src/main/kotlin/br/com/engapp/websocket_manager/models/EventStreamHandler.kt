import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.EventChannel

class EventStreamHandler(onNullSink:()->Unit, onCancelCallback: () -> Unit) : EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    private val onNullSink = onCancelCallback
    private val onCancelCallback = onCancelCallback

//    override fun onReceive(context: Context?, intent: Intent?) {
//        Log.i("EventStreamHandler","onReceive")
//        TODO("not implemented")
//    }

//    override fun onListen(arguments: Any, eventSink: EventChannel.EventSink) {
//        Log.i("EventStreamHandler","event sink")
//        this.sink = eventSink
//    }
    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        Log.i("onListen", "arguments: $arguments")
        Log.i("EventStreamHandler","🔴 event sink")
        this.sink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        Log.i("EventStreamHandler","onCancel")
        this.sink = null
        onCancelCallback()
    }

    fun send(data: Any?){
        if (this.sink != null) {
            Log.i("EventStreamHandler","✅ sink is not null")
            try {
                sink!!.success(data)
            }catch (e: Exception){
                Log.i("EventStreamHandler","Exception while trying to send data: $data")
                Log.i("EventStreamHandler","Exception: ${e.message}")
                println(e.message)
            }
        } else {
            Log.i("EventStreamHandler", "❌ sink is null")
            onNullSink()
        }
    }
}
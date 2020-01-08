package br.com.engapp.websocket_manager

import android.app.Activity
import android.app.IntentService
import android.util.Log
import okhttp3.WebSocket
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.WebSocketListener
import java.util.*
import okhttp3.Response
import okio.ByteString


class StreamWebSocketManager(private val activity: Activity): WebSocketListener() {

    private var ws: WebSocket? = null
    private val client = OkHttpClient()
    private var url: String? = null
    private var header: Map<String,String>? = null
    var updatesEnabled = false

    var messageCallback: ((String)->Unit)? = null
    var closeCallback: ((String)->Unit)? = null
    var conectedCallback: ((Boolean)->Unit)? = null
    var openCallback: ((String)->Unit)? = null

    var enableRetries: Boolean = true

    init {
        // print(">>> Stream Manager Instantiated")
        // Log.i("StreamWebSocketManager",">>> Stream Manager Instantiated")
    }

    override fun onOpen(webSocket: WebSocket, response: Response) {
        Log.i("StreamWebSocketManager","onOpen")
        // Log.i("StreamWebSocketManager","is open callback null? ${openCallback == null}")
        if(openCallback != null) {
            activity.runOnUiThread {
                openCallback!!(response.message)
            }
        }
    }
    override fun onMessage(webSocket: WebSocket, text: String) {
        Log.i("StreamWebSocketManager","onMessage text")
        if(messageCallback != null) {
            activity.runOnUiThread {
                messageCallback!!(text)
            }
        }
    }

    override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
        Log.i("StreamWebSocketManager","onMessage bytes")
        //
    }

    override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
        Log.i("StreamWebSocketManager","🐞 onFailure ${t.message}")
        // Log.i("StreamWebSocketManager","🐞 ${t.message}")
        t.printStackTrace()
        activity.runOnUiThread {
            if(this.enableRetries) {
                this.connect()
            } else {
                if (closeCallback != null) {
                    closeCallback!!("true")
                }
            }
        }
    }

    override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
        Log.i("StreamWebSocketManager","onClosing")
        activity.runOnUiThread {
            if(this.enableRetries) {
                this.connect()
            } else {
                if (closeCallback != null) {
                    closeCallback!!("false")
                }
            }
        }
    }

    fun echoTest() {
        // Log.i("StreamWebSocketManager","init echoTest")
        var messageNum = 0
        fun send() {
            messageNum+=1
            val msg = "$messageNum: ${Date()}"
            // print("send: $msg")
            // Log.i("StreamWebSocketManager","send: $msg")
            ws?.send(msg)
        }
        openCallback = fun (text: String): Unit {
            send()
        }
        messageCallback = fun (text: String): Unit {
            // print("recv: $text")
            // Log.i("StreamWebSocketManager","recv: $text")
            if(messageNum == 10) {
                ws?.close(1000,null)
            } else {
                send()
            }
        }
        closeCallback = fun (text: String): Unit {
            // print("close $text")
            // Log.i("StreamWebSocketManager","close $text")
        }

        url = "wss://echo.websocket.org"
        connect()
    }

    fun create(url: String, header: Map<String,String>?) {
        this.url = url
        this.header = header
    }

    fun connect() {
        // Log.i("StreamWebSocketManager","Trying to connect")
        val reqBuilder: Request.Builder = Request.Builder().url(url!!)
        if(header != null) {
            // Log.i("StreamWebSocketManager","has headers")
            for(key in header!!.keys) {
                val value: String = (header!![key])!!
                reqBuilder.addHeader(key, value)
            }
        } else {
            // Log.i("StreamWebSocketManager","has no headers")
        }
        val req: Request = reqBuilder.build()
        // Log.i("StreamWebSocketManager","method: ${req.method}")
        // Log.i("StreamWebSocketManager","url: ${req.url}")
        ws = client.newWebSocket(req,this)
//        client.dispatcher.executorService.shutdown()
    }

    fun disconnect() {
        enableRetries = false
        ws?.close(1000,null)
    }

    fun send(msg: String) {
        // Log.i("StreamWebSocketManager","⭕️ -> sending $msg")
        // Log.i("StreamWebSocketManager","⭕️ -> ws is null? ${ws == null}")
        ws?.send(msg)
    }
}
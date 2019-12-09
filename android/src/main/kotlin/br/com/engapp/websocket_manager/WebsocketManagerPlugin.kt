package br.com.engapp.websocket_manager

import EventStreamHandler
import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class ChannelName {
  companion object {
    const val PLUGIN_NAME = "websocket_manager"
    const val MESSAGE = "websocket_manager/message"
    const val DONE = "websocket_manager/done"
  }
}

class MethodName {
  companion object {
    const val PLATFORM_VERSION = "getPlatformVersion"
    const val CREATE = "create"
    const val CONNECT = "connect"
    const val DISCONNECT = "disconnect"
    const val SEND_MESSAGE = "send"
    const val AUTO_RETRY = "autoRetry"
    const val ON_MESSAGE = "onMessage"
    const val ON_DONE = "onDone"
    const val TEST_ECHO = "echoTest"
  }
}

class WebsocketManagerPlugin(registrar: Registrar): MethodCallHandler {
  private var methodChannel: MethodChannel? = null

  private val messageStreamHandler = EventStreamHandler(this::onCancelCallback)
  private val closeStreamHandler = EventStreamHandler(this::onCancelCallback)
  private val websocketManager = StreamWebSocketManager(registrar.activity())

  private fun setupChannels(messenger: BinaryMessenger, context: Context) {

    methodChannel = MethodChannel(messenger, ChannelName.PLUGIN_NAME)
    methodChannel!!.setMethodCallHandler(this)

    val messageChannel = EventChannel(messenger, ChannelName.MESSAGE)
    messageChannel.setStreamHandler(messageStreamHandler)
    val doneChannel = EventChannel(messenger, ChannelName.DONE)
    doneChannel.setStreamHandler(closeStreamHandler)
  }

  init {
    Log.i("WebsocketManagerPlugin","init 🤪")
    setupChannels(registrar.messenger(), registrar.activeContext())
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      WebsocketManagerPlugin(registrar)
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    // Log.i("WebsocketManagerPlugin","Calling: ${call.method}")
    when (call.method) {
      MethodName.PLATFORM_VERSION -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      MethodName.CREATE -> {
        val url: String? = call.argument<String>("url")
        val header:Map<String,String>? = call.argument<Map<String,String>>("header")
        // Log.i("WebsocketManagerPlugin","url: $url")
        // Log.i("WebsocketManagerPlugin","header: $header")
        websocketManager.create(url!!, header)
        websocketManager.messageCallback = fun (msg: String) {
          // Log.i("WebsocketManagerPlugin","sending $msg")
          messageStreamHandler.send(msg)
        }
        websocketManager.closeCallback = fun (msg: String) {
          // print("closed $msg")
          closeStreamHandler.send(msg)
        }
        result.success("")
      }
      MethodName.CONNECT -> {
        websocketManager.connect()
        result.success("")
      }
      MethodName.DISCONNECT -> {
        websocketManager.disconnect()
        result.success("")
      }
      MethodName.SEND_MESSAGE -> {
        val message: String = call.arguments()!!
        websocketManager.send(message)
        result.success("")
      }
      MethodName.AUTO_RETRY -> {
        var retry:Boolean? = call.arguments()
        if(retry == null) {
          retry = true
        }
        websocketManager.enableRetries = retry
        result.success("")
      }
      MethodName.ON_MESSAGE -> {
        websocketManager.messageCallback = fun (msg: String) {
          // Log.i("WebsocketManagerPlugin","sending $msg")
          messageStreamHandler.send(msg)
        }
        result.success("")
      }
      MethodName.ON_DONE -> {
        websocketManager.closeCallback = fun (msg: String) {
          // print("closed $msg")
          closeStreamHandler.send(msg)
        }
        result.success("")
      }
      MethodName.TEST_ECHO -> {
        websocketManager.echoTest()
        // Log.i("WebsocketManagerPlugin","echo test")
        result.success("echo test")
      }
      else -> result.notImplemented()
    }
  }

  private fun onCancelCallback(){
    //
  }
}

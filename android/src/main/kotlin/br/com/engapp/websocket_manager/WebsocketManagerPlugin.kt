package br.com.engapp.websocket_manager

import EventStreamHandler
import android.content.Context
import br.com.engapp.websocket_manager.models.ChannelName
import br.com.engapp.websocket_manager.models.MethodName
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar


class WebsocketManagerPlugin: FlutterPlugin {
  private var methodChannel: MethodChannel? = null

  private var messageChannel: EventChannel? = null
  private var doneChannel: EventChannel? = null
  private val messageStreamHandler = EventStreamHandler(this::onListenMessageCallback, this::onCancelCallback)
  private val closeStreamHandler = EventStreamHandler(this::onListenCloseCallback, this::onCancelCallback)

  /** Plugin registration.  */
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val plugin = WebsocketManagerPlugin()
      plugin.setupChannels(registrar.messenger(), registrar.context())
    }
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    setupChannels(binding.binaryMessenger, binding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    teardownChannels()
  }

  private fun setupChannels(messenger: BinaryMessenger, context: Context) {

    val websocketMethodChannel = WebSocketMethodChannelHandler(messageStreamHandler, closeStreamHandler)
    methodChannel = MethodChannel(messenger, ChannelName.PLUGIN_NAME)
    methodChannel!!.setMethodCallHandler(websocketMethodChannel)

    messageChannel = EventChannel(messenger, ChannelName.MESSAGE)
    messageChannel!!.setStreamHandler(messageStreamHandler)
    doneChannel = EventChannel(messenger, ChannelName.DONE)
    doneChannel!!.setStreamHandler(closeStreamHandler)
  }

  private fun teardownChannels() {
    methodChannel?.setMethodCallHandler(null)
    messageChannel?.setStreamHandler(null)
    doneChannel?.setStreamHandler(null)
    methodChannel = null
    messageChannel = null
    doneChannel = null
  }

  private fun onListenMessageCallback(){
    methodChannel?.invokeMethod(MethodName.LISTEN_MESSAGE,null)
  }
  private fun onListenCloseCallback(){
    methodChannel?.invokeMethod(MethodName.LISTEN_CLOSE,null)
  }
  private fun onCancelCallback(){
    //
  }
}

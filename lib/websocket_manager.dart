import 'dart:async';

import 'package:flutter/services.dart';

const String _PLUGIN_NAME = 'websocket_manager';
const String _EVENT_CHANNEL_MESSAGE = 'websocket_manager/message';
const String _EVENT_CHANNEL_DONE = '$_PLUGIN_NAME/done';
const String _METHOD_CHANNEL_CREATE = 'create';
const String _METHOD_CHANNEL_CONNECT = 'connect';
const String _METHOD_CHANNEL_DISCONNECT = 'disconnect';
const String _METHOD_CHANNEL_ON_MESSAGE = 'onMessage';
const String _METHOD_CHANNEL_ON_DONE = 'onDone';
const String _METHOD_CHANNEL_SEND = 'send';
const String _METHOD_CHANNEL_TEST_ECHO = 'echoTest';

/// Provides an easy way to create native websocket connection.
class WebsocketManager {
  WebsocketManager(this.url, [this.header]) {
    _create();
  }

  final String url;
  final Map<String, String> header;

  static const MethodChannel _channel = MethodChannel(_PLUGIN_NAME);
  static const EventChannel _eventChannelMessage =
      EventChannel(_EVENT_CHANNEL_MESSAGE);
  static const EventChannel _eventChannelClose =
      EventChannel(_EVENT_CHANNEL_DONE);
  static StreamSubscription<dynamic> _onMessageSubscription;
  static StreamSubscription<dynamic> _onCloseSubscription;
  static Stream<dynamic> _eventsMessage;
  static Stream<dynamic> _eventsClose;
  static Function(dynamic) _messageCallback;
  static Function(dynamic) _closeCallback;

  static Future<void> echoTest() async {
    final dynamic result =
        await _channel.invokeMethod<dynamic>(_METHOD_CHANNEL_TEST_ECHO);
    print(result);
  }

  Future<void> _create() async {
    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case 'listen/message':
          _onMessage();
          break;
        case 'listen/close':
          _onClose();
          break;
      }
      return;
    });
    // print(url);
    // print(header);
    await _channel
        .invokeMethod<dynamic>(_METHOD_CHANNEL_CREATE, <String, dynamic>{
      'url': url,
      'header': header,
    });
    _onMessage();
    _onClose();
  }

  /// Creates a new WebSocket connection after instantiated [WebsocketManager].
  ///
  /// From this point the messages are being listened, but you need to
  /// call [onMessage] or [onClose] functions, providing a callback function,
  /// to be able to listen data sent from the server and a done event.
  Future<void> connect() async {
    _onMessage();
    await _channel.invokeMethod<dynamic>(_METHOD_CHANNEL_CONNECT);
  }

  /// Closes the web socket connection.
  Future<void> close() async {
    await _channel.invokeMethod<String>(_METHOD_CHANNEL_DISCONNECT);
    _eventsMessage = null;
    if (_onMessageSubscription != null) {
      _onMessageSubscription.cancel();
      _onMessageSubscription = null;
    }
//    _eventsClose = null;
//    if (_onCloseSubscription != null) {
//      _onCloseSubscription.cancel();
//      _onCloseSubscription = null;
//    }
  }

  /// Send a [String] message to the connected WebSocket.
  void send(String message) {
    _channel.invokeMethod<dynamic>(_METHOD_CHANNEL_SEND, message);
  }

  /// Adds a callback handler to this WebSocket sent data.
  ///
  /// On each data event from this WebSocket, the subscriber's [onMessage] handler
  /// is called. If [onMessage] is `null`, nothing happens.
  ///
  /// If you received any message before setting this callback handler
  /// you are not going to received past data.
  void onMessage(Function(dynamic) callback) {
    _messageCallback = callback;
    _startMessageServices().then((_) {
      _onMessage();
    });
  }

  /// Adds a callback handler to this WebSocket close event.
  ///
  /// If this WebSocket closes a done event is triggered, the [onClose] handler is
  /// called. If [onClose] is `null`, nothing happens.
  ///
  /// If you are not listening to this close event you are not going to be able
  /// to know if the connection was closed.
  void onClose(Function(dynamic) callback) {
    _closeCallback = callback;
    _startCloseServices().then((_) {
      _onClose();
    });
  }

  Future<void> _startMessageServices() async {
    await _channel.invokeMethod<String>(_METHOD_CHANNEL_ON_MESSAGE);
    return;
  }

  void _onMessage() {
    if (_eventsMessage == null) {
      _eventsMessage =
          _eventChannelMessage.receiveBroadcastStream().asBroadcastStream();
      _onMessageSubscription = _eventsMessage.listen(_messageListener);
    }
  }

  Future<void> _startCloseServices() async {
    await _channel.invokeMethod<dynamic>(_METHOD_CHANNEL_ON_DONE);
    return;
  }

  void _onClose() {
    if (_eventsClose == null) {
      _eventsClose = _eventChannelClose.receiveBroadcastStream();
      _onCloseSubscription = _eventsClose.listen(_closeListener);
    }
  }

  void _messageListener(dynamic message) {
    // print('Received message: $message');
    if (_messageCallback != null) {
      _messageCallback(message);
    }
  }

  void _closeListener(dynamic message) {
    print(message);
    if (_closeCallback != null) {
      _closeCallback(message);
    }
  }
}

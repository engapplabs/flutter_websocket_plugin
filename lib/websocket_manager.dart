import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

const _PLUGIN_NAME = 'websocket_manager';
const _EVENT_CHANNEL_MESSAGE = '$_PLUGIN_NAME/message';
const _EVENT_CHANNEL_DONE = '$_PLUGIN_NAME/done';
const _METHOD_CHANNEL_CREATE = 'create';
const _METHOD_CHANNEL_CONNECT = 'connect';
const _METHOD_CHANNEL_DISCONNECT = 'disconnect';
const _METHOD_CHANNEL_ON_MESSAGE = 'onMessage';
const _METHOD_CHANNEL_ON_DONE = 'onDone';
const _METHOD_CHANNEL_SEND = 'send';

class WebsocketManager {
  WebsocketManager(this.url, [this.header]) {
    _create();
  }

  final String url;
  final Map<String,String> header;

  static const MethodChannel _channel = const MethodChannel(_PLUGIN_NAME);
  static const EventChannel _eventChannelMessage =
    const EventChannel(_EVENT_CHANNEL_MESSAGE);
  static const EventChannel _eventChannelClose =
    const EventChannel(_EVENT_CHANNEL_DONE);
  static StreamSubscription _onMessageSubscription;
  static StreamSubscription _onCloseSubscription;
  static Stream<dynamic> _eventsMessage;
  static Stream<dynamic> _eventsClose;
  static Function(dynamic) _messageCallback;
  static Function(dynamic) _closeCallback;

  static bool _keepAlive = false;

  Future<void> _create() {
    print(url);
    print(header);
    _channel.invokeMethod(_METHOD_CHANNEL_CREATE, <String, dynamic>{
      'url': url,
      'header': header,
    });
  }

  Future<void> connect() {
    _channel.invokeMethod(_METHOD_CHANNEL_CONNECT);
  }

  void close() {
    _keepAlive = false;
    if(_onMessageSubscription != null) {
      _onMessageSubscription.cancel();
      _onMessageSubscription = null;
    }
    _channel.invokeMethod<String>(_METHOD_CHANNEL_DISCONNECT);
  }

  Future<void> send(String message) {
    _channel.invokeMethod(_METHOD_CHANNEL_SEND, message);
  }

  Future<void> onMessage(Function(dynamic) callback) {
    _messageCallback = callback;
    _startMessageServices().then((_) {
      _onMessage();
      _onMessageSubscription = _eventsMessage.listen(_messageListener,
        onDone: () {
          if(_closeCallback != null) {
            _closeCallback('CLOSED');
          }
        },
        cancelOnError: true);
    });
  }

  Future<void> onClose(Function(dynamic) callback) {
    _closeCallback = callback;
    _startCloseServices().then((_) {
      _onClose();
      _onCloseSubscription = _eventsClose.listen(_closeListener);
    });
  }

  Future<void> _startMessageServices() async {
    await _channel.invokeMethod<String>(_METHOD_CHANNEL_ON_MESSAGE);
    return;
  }

  void _onMessage() {
    _keepAlive = true;
    if (_eventsMessage == null) {
      _eventsMessage = _eventChannelMessage.receiveBroadcastStream().where(
          (_) => _keepAlive);
    }
  }

  Future<void> _startCloseServices() async {
    await _channel.invokeMethod<dynamic>(_METHOD_CHANNEL_ON_DONE);
    return;
  }

  void _onClose() {
    if (_eventsClose == null) {
      _eventsClose = _eventChannelClose.receiveBroadcastStream().where(
          (_) => true);
    }
  }

  void _messageListener(dynamic message) {
    if(_messageCallback != null) {
      _messageCallback(message);
    }
  }

  void _closeListener(dynamic message) {
    print(message);
    if(_closeCallback != null) {
      _closeCallback(message);
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:websocket_manager/websocket_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  int _currentIndex = 0;
  final TextEditingController _urlController =
      TextEditingController(text: 'wss://echo.websocket.org');
  final TextEditingController _messageController = TextEditingController();
  WebsocketManager socket;
  String _message = '';
  String _closeMessage = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Websocket Manager Example'),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
            ),
            Wrap(
              children: <Widget>[
                RaisedButton(
                  child: Text('CONFIG'),
                  onPressed: () =>
                      socket = WebsocketManager(_urlController.text),
                ),
                RaisedButton(
                  child: Text('CONNECT'),
                  onPressed: () {
                    if (socket != null) {
                      socket.connect();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('CLOSE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.close();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN MESSAGE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.onMessage((dynamic message) {
                        print('New message: $message');
                        setState(() {
                          _message = message.toString();
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN DONE'),
                  onPressed: () {
                    if (socket != null) {
                      socket.onClose((dynamic message) {
                        print('Close message: $message');
                        setState(() {
                          _closeMessage = message.toString();
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('ECHO TEST'),
                  onPressed: () => WebsocketManager.echoText(),
                ),
                RaisedButton(
                  child: Text('TEST'),
                  onPressed: () {
                    socket = WebsocketManager(
                      'ws://rel.maju.com.br:9000/ws/v1/driver',
                      <String, String>{
                        'Authorization':
                            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Imx1YW5oc3NhQGdtYWlsLmNvbSIsImlkIjoiNjY2OTVlOGUtODM4OC00MWM3LWEyNmEtYzVkZmQ4YTFmOWYwIn0.ML6jTvFDYHtYaJSwMg38FPi7k3f0gwjQ3Ujf7DC4Gto',
                        'score': '500',
                        'category': '0',
                        'car_plate': 'TEST0000',
                        'driver_id': '66695e8e-8388-41c7-a26a-c5dfd8a1f9f0',
                      },
                    );
                  },
                ),
              ],
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (socket != null) {
                      socket.send(_messageController.text);
                    }
                  },
                ),
              ),
            ),
            Text('Received message:'),
            Text(_message),
            Text('Close message:'),
            Text(_closeMessage),
          ],
        ),
      ),
    );
  }
}

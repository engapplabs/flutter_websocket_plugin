import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:websocket_manager/websocket_manager.dart';

void main() {
  const MethodChannel channel = MethodChannel('websocket_manager');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

//  test('getPlatformVersion', () async {
//    expect(await WebsocketManager.platformVersion, '42');
//  });
}

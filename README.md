
---

**NOTE**: This repository is no longer maintained by ENGAPP. It was moved to be maintained by [Kunlatek](https://github.com/kunlatek/flutter_websocket_manager_plugin) on the following link:
https://github.com/kunlatek/flutter_websocket_manager_plugin

Any issue regarding this plugin should be reported there. 

---

# Websocket Manager

A Flutter plugin for Android and iOS supports websockets. This plugin is based on two different native libraries [Starscream](https://github.com/daltoniam/Starscream) for iOS and [okHttp](https://medium.com/@ssaurel/learn-to-use-websockets-on-android-with-okhttp-ba5f00aea988) for Android.

This plugin was created due to our necessity to maintain a WebSocket connection active in background while [Flutter's WebSocket](https://flutter.dev/docs/cookbook/networking/web-sockets) from cookbook doesn't keep alive while screen is locked or the application was in background.

## Introduction

**Websocket Manager** doesn't manipulate websockets in Dart codes directly, instead, the plugin uses Platform Channel to expose Dart APIs that Flutter application can use to communicate with two very powerful websocket native libraries. Because of that, all credits belong to these libraries.

## How to install

### Android

**You only need this configuration if your server doesn't have SSL/TLS**

Since Android P http is blocked by default and there are many ways to configure. One way to configure is explicitly saying that you accept clear text for some host.

- Create res/xml/network_security_config.xml with content:

````xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">your_domain</domain>
    </domain-config>
</network-security-config>
````

- Point to this file from your manifest (for bonus points add it only for the test manifest):

````xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    android:label="@string/app_name"
    android:theme="@style/AppTheme">
    <activity android:name=" (...)
</application>
````

### iOS

Doesn't require any configuration

## Example

````dart
int messageNum = 0;
// Configure WebSocket url
final socket = WebsocketManager('wss://echo.websocket.org');
// Listen to close message
socket.onClose((dynamic message) {
    print('close');
});
// Listen to server messages
socket.onMessage((dynamic message) {
    print('recv: $message');
    if messageNum == 10 {
        socket.close();
    } else {
        messageNum += 1;
        final String msg = '$messageNum: ${DateTime.now()}';
        print('send: $msg');
        socket.send(msg);
    }
});
// Connect to server
socket.connect();
````

## Credits

- Android: [okHttp](https://medium.com/@ssaurel/learn-to-use-websockets-on-android-with-okhttp-ba5f00aea988) created by [Square](https://github.com/square)
- iOS: [Starscream](https://github.com/daltoniam/Starscream) created by [daltoniam](https://github.com/daltoniam)

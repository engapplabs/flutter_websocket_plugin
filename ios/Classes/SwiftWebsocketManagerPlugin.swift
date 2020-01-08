import Flutter
import UIKit

enum ChannelName {
    static let onMessage: String = "websocket_manager/message"
    static let onDone: String = "websocket_manager/done"
    static let status: String = "websocket_manager/status"
}

@available(iOS 9.0, *)
public class SwiftWebsocketManagerPlugin: NSObject, FlutterPlugin {
    let messageStreamHandler = EventStreamHandler()
    let closeStreamHandler = EventStreamHandler()
    let statusStreamHandler = EventStreamHandler()
    let streamWebSocketManager = StreamWebSocketManager()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "websocket_manager", binaryMessenger: registrar.messenger())
        let instance = SwiftWebsocketManagerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        instance.eventChannelRegister(registrar)

        registrar.addApplicationDelegate(instance)
    }

    func eventChannelRegister(_ registrar: FlutterPluginRegistrar) {
        // Stream setup
        FlutterEventChannel(name: ChannelName.onMessage, binaryMessenger: registrar.messenger())
            .setStreamHandler(messageStreamHandler)
        FlutterEventChannel(name: ChannelName.onDone, binaryMessenger: registrar.messenger())
            .setStreamHandler(closeStreamHandler)
        FlutterEventChannel(name: ChannelName.status, binaryMessenger: registrar.messenger())
            .setStreamHandler(statusStreamHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "create" {
            let arguments = call.arguments as! [String: Any]
            let url = arguments["url"] as! String
            // print(url)
            let header = arguments["header"] as? [String: String]
            // print(header as Any)
            var enableRetries = arguments["enableRetries"] as? Bool
            if enableRetries == nil {
                enableRetries = true
            }
            streamWebSocketManager.create(url: url, header: header, enableCompression: arguments["enableCompression"] as? Bool, disableSSL: arguments["disableSSL"] as? Bool,
                                          enableRetries: enableRetries!)

            streamWebSocketManager.closeCallback = closeHandler
            streamWebSocketManager.onClose()
            result("")
        } else if call.method == "connect" {
            streamWebSocketManager.connect()
            result("")
        } else if call.method == "disconnect" {
            streamWebSocketManager.disconnect()
            result("")
        } else if call.method == "send" {
            let message = call.arguments as! String
            // print(message)
            streamWebSocketManager.send(string: message)
            result("")
        } else if call.method == "autoRetry" {
            var retry = call.arguments as? Bool
            if retry == nil {
                retry = true
            }
            streamWebSocketManager.enableRetries = retry!
            result("")
        } else if call.method == "echoTest" {
            streamWebSocketManager.echoTest()
            result("")
        } else if call.method == "onMessage" {
            streamWebSocketManager.closeCallback = closeHandler
            streamWebSocketManager.onClose()

            streamWebSocketManager.messageCallback = resultHander
            streamWebSocketManager.onText()
            // print("listening")
            result("")
        } else if call.method == "onDone" {
            streamWebSocketManager.closeCallback = closeHandler
            streamWebSocketManager.onClose()
            result("")
        }
    }

    func resultHander(msg: String) {
        messageStreamHandler.send(data: msg)
    }

    func closeHandler(msg: String) {
        // print("closed \(msg)")
        closeStreamHandler.send(data: msg)
    }
}

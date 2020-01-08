//
//  StreamManager.swift
//  websocket_manager
//
//  Created by Luan Almeida on 15/11/19.
//

import Starscream

@available(iOS 9.0, *)
class StreamWebSocketManager: NSObject, WebSocketDelegate {
    var ws: WebSocket?
    var updatesEnabled = false

    var messageCallback: ((_ data: String) -> Void)?
    var closeCallback: ((_ data: String) -> Void)?
    var conectedCallback: ((_ data: Bool) -> Void)?

    var enableRetries: Bool = true

    override init() {
        super.init()

        // print(">>> Stream Manager Instantiated")
    }

    required init(coder _: NSCoder) {
        fatalError(">>> init(coder:) has not been implemented")
    }

    func areUpdateEnabled() -> Bool { return updatesEnabled }

    func create(url: String, header: [String: String]?, enableCompression _: Bool?, disableSSL _: Bool?, enableRetries: Bool) {
        var request = URLRequest(url: URL(string: url)!)
        if header != nil {
            for key in header!.keys {
                request.setValue(header![key], forHTTPHeaderField: key)
            }
        }
        self.enableRetries = enableRetries
        print(request.allHTTPHeaderFields as Any)
        ws = WebSocket(request: request)
        ws?.delegate = self
//        if(enableCompression != nil) {
//            ws?.enableCompression = enableCompression!
//        } else {
//            ws?.enableCompression = true
//        }
//        if(disableSSL != nil) {
//            ws?.disableSSLCertValidation = disableSSL!
//        } else {
//            ws?.disableSSLCertValidation = false
//        }
        onConnect()
        onClose()
    }

    func onConnect() {
        ws?.onConnect = {
            // print("opened")
            if self.conectedCallback != nil {
                (self.conectedCallback!)(true)
            }
        }
    }

    func connect() {
        onText()
        ws?.connect()
    }

    func disconnect() {
        enableRetries = false
        ws?.disconnect()
    }

    func send(string: String) {
        ws?.write(string: string)
    }

    func onText() {
        ws?.onText = { (text: String) in
            // print("recv: \(text)")
            if self.messageCallback != nil {
                (self.messageCallback!)(text)
            }
        }
    }

    func onClose() {
        ws?.onDisconnect = { (error: Error?) in
             print("close \(String(describing: error).debugDescription)")
            if self.enableRetries {
                self.connect()
            } else {
                if self.conectedCallback != nil {
                    (self.conectedCallback!)(false)
                }
                if self.closeCallback != nil {
                    if error != nil {
                        if error is WSError {
                            // print("Error message: \((error as! WSError).message)")
                        }
                        (self.closeCallback!)("false")
                        print("close callback calling false")
                    } else {
                        (self.closeCallback!)("true")
                        print("close callback calling true")
                    }
                } else {
                    print("close callback is nil")
                }
            }
        }
    }

    func isConnected() -> Bool {
        if ws == nil {
            return false
        } else {
            return ws!.isConnected
        }
    }

    func echoTest() {
        var messageNum = 0
        ws = WebSocket(url: URL(string: "wss://echo.websocket.org")!)
        ws?.delegate = self
        let send: () -> Void = {
            messageNum += 1
            let msg = "\(messageNum): \(NSDate().description)"
            // print("send: \(msg)")
            self.ws?.write(string: msg)
        }
        ws?.onConnect = {
            // print("opened")
            send()
        }
        ws?.onDisconnect = { (_: Error?) in
            // print("close")
        }
        ws?.onText = { (_: String) in
            // print("recv: \(text)")
            if messageNum == 10 {
                self.ws?.disconnect()
            } else {
                send()
            }
        }
        ws?.connect()
    }

    func websocketDidConnect(socket _: WebSocketClient) {
        //
    }

    func websocketDidDisconnect(socket _: WebSocketClient, error _: Error?) {
        //
    }

    func websocketDidReceiveMessage(socket _: WebSocketClient, text _: String) {
        //
    }

    func websocketDidReceiveData(socket _: WebSocketClient, data _: Data) {
        //
    }
}

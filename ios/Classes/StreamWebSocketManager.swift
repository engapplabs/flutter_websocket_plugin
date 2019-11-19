//
//  StreamManager.swift
//  websocket_manager
//
//  Created by Luan Almeida on 15/11/19.
//

import Starscream

@available(iOS 9.0, *)
class StreamWebSocketManager: NSObject, WebSocketDelegate {
    
    var ws: WebSocket? = nil
    var updatesEnabled = false
    
    var messageCallback: ((_ data: String)-> ())?
    var closeCallback: ((_ data: String)-> ())?
    var conectedCallback: ((_ data: Bool)-> ())?
    
    var enableRetries: Bool = true

    override init () {

        super.init()

        print(">>> Stream Manager Instantiated")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError(">>> init(coder:) has not been implemented")
    }
    
    func areUpdateEnabled() -> Bool {return self.updatesEnabled}
    
    func create(url: String, header: Dictionary<String,String>?, enableCompression: Bool?, disableSSL: Bool?, enableRetries: Bool) {
        var request = URLRequest(url: URL(string: url)!)
        if(header != nil) {
            for key in header!.keys {
                request.setValue((header![key]), forHTTPHeaderField: key)
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
            print("opened")
            if(self.conectedCallback != nil) {
                (self.conectedCallback!)(true)
            }
        }
    }
    
    func connect() {
        onText()
        ws?.connect()
    }
    
    func disconnect() {
        ws?.disconnect()
    }
    
    func send(string: String) {
        ws?.write(string: string)
    }
    
    func onText() {
        ws?.onText = { (text: String) in
            print("recv: \(text)")
            if(self.messageCallback != nil) {
                (self.messageCallback!)(text)
            }
        }
    }
    
    func onClose() {
        ws?.onDisconnect = { (error: Error?) in
            print("close \(String(describing: error).debugDescription)")
            if(self.enableRetries) {
                self.connect()
            } else {
                if(self.conectedCallback != nil) {
                    (self.conectedCallback!)(false)
                }
                if(self.closeCallback != nil) {
                    if(error != nil) {
                        if(error is WSError) {
                            print("Error message: \((error as! WSError).message)")
                        }
                        (self.closeCallback!)("false")
                    } else {
                        (self.closeCallback!)("true")
                    }
                }
            }
        }
    }
    
    func isConnected() -> Bool{
        if(ws == nil) {
            return false
        } else {
            return self.ws!.isConnected
        }
    }
    
    func echoTest() {
        var messageNum = 0
        ws = WebSocket(url: URL(string: "wss://echo.websocket.org")!)
        ws?.delegate = self
        let send : ()->() = {
            messageNum+=1
            let msg = "\(messageNum): \(NSDate().description)"
            print("send: \(msg)")
            self.ws?.write(string: msg)
        }
        ws?.onConnect = {
            print("opened")
            send()
        }
        ws?.onDisconnect = { (error: Error?) in
            print("close")
        }
        ws?.onText = { (text: String) in
            print("recv: \(text)")
            if messageNum == 10 {
                self.ws?.disconnect()
            } else {
                send()
            }
        }
        ws?.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        //
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        //
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        //
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        //
    }
}

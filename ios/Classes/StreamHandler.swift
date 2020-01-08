//
//  StreamHandler.swift
//  Pods-Runner
//
//  Created by Luan Almeida on 15/11/19.
//

import Flutter

class EventStreamHandler : NSObject, FlutterStreamHandler {
    
    var sink:FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        self.sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.sink = nil
        return nil
    }
    
    func send(data: Any) {
        if let sink = self.sink {
            print("sink \(data)")
            sink(data)
        } else {
            print("sink is null")
        }
    }
}

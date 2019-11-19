#import "WebsocketManagerPlugin.h"
#import <websocket_manager/websocket_manager-Swift.h>

@implementation WebsocketManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWebsocketManagerPlugin registerWithRegistrar:registrar];
}
@end

#if __has_include(<React/RCTConvert.h>)
#import <React/RCTConvert.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#else
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"
#endif

#import "RCTCleverPush.h"
#import "RCTCleverPushEventEmitter.h"

#if __IPHONE_CP_VERSION_MIN_REQUIRED < __IPHONE_8_0

#define UIUserNotificationTypeAlert UIRemoteNotificationTypeAlert
#define UIUserNotificationTypeBadge UIRemoteNotificationTypeBadge
#define UIUserNotificationTypeSound UIRemoteNotificationTypeSound
#define UIUserNotificationTypeNone  UIRemoteNotificationTypeNone
#define UIUserNotificationType      UIRemoteNotificationType

#endif

@interface RCTCleverPush ()
@end

@implementation RCTCleverPush {
    BOOL didInitialize;
}

CPNotificationOpenedResult* coldStartCPNotificationOpenedResult;

+ (RCTCleverPush *) sharedInstance {
    static dispatch_once_t token = 0;
    static id _sharedInstance = nil;
    dispatch_once(&token, ^{
        _sharedInstance = [[RCTCleverPush alloc] init];
    });
    return _sharedInstance;
}

- (void)initCleverPush {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginObserving) name:@"didSetBridge" object:nil];
    
    [CleverPush initWithLaunchOptions:nil channelId:nil handleNotificationOpened:^(CPNotificationOpenedResult* result) {
        [self handleRemoteNotificationOpened:[result stringify]];
    }];
    didInitialize = false;
}

- (void)didBeginObserving {
    RCTCleverPush.sharedInstance.didStartObserving = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (coldStartCPNotificationOpenedResult) {
            [self handleRemoteNotificationOpened:[coldStartCPNotificationOpenedResult stringify]];
            coldStartCPNotificationOpenedResult = nil;
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureWithChannelId:(NSString *)channelId {
    if (didInitialize)
        return;
    
    didInitialize = true;
    [CleverPush initWithLaunchOptions:nil channelId:channelId handleNotificationOpened:^(CPNotificationOpenedResult *result) {
        if (!RCTCleverPush.sharedInstance.didStartObserving) {
             coldStartCPNotificationOpenedResult = result;
        } else {
             [self handleRemoteNotificationOpened:[result stringify]];
        }
  }];
}

- (void)handleRemoteNotificationOpened:(NSString *)result {
    NSDictionary *json = [self jsonObjectWithString:result];
    
    if (json)
        [self sendEvent:CPEventString(NotificationOpened) withBody:json];
}

- (NSDictionary *)jsonObjectWithString:(NSString *)jsonString {
    NSError *jsonError;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    
    if (jsonError) {
        NSLog(@"CleverPush: Unable to serialize JSON string into an object: %@", jsonError);
        return nil;
    }
    
    return json;
}

- (void)sendEvent:(NSString *)eventName withBody:(NSDictionary *)body {
    [RCTCleverPushEventEmitter sendEventWithName:eventName withBody:body];
}

@end

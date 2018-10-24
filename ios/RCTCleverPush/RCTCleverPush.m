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

- (NSString*)stringifyNotificationOpenedResult:(CPNotificationOpenedResult*)result {
    NSMutableDictionary* obj = [NSMutableDictionary new];
    [obj setObject:result.notification forKeyedSubscript:@"notification"];
    [obj setObject:result.subscription forKeyedSubscript:@"subscription"];

    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:obj options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)initCleverPush {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginObserving) name:@"didSetBridge" object:nil];
    
    [CleverPush initWithLaunchOptions:nil channelId:nil handleNotificationOpened:^(CPNotificationOpenedResult* result) {
        NSLog(@"CP_EVENT: initCleverPush: notificationOpened");
        [self handleNotificationOpened:[self stringifyNotificationOpenedResult:result]];
    } handleSubscribed:^(NSString *result) {
        NSLog(@"CP_EVENT: initCleverPush: handleSubscribed");
        [self handleSubscribed:result];
    }];
    didInitialize = false;
}

- (void)didBeginObserving {
    RCTCleverPush.sharedInstance.didStartObserving = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (coldStartCPNotificationOpenedResult) {
            [self handleNotificationOpened:[self stringifyNotificationOpenedResult:coldStartCPNotificationOpenedResult]];
            coldStartCPNotificationOpenedResult = nil;
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)init:(NSString *)channelId {
    if (didInitialize)
        return;
    
    didInitialize = true;
    [CleverPush initWithLaunchOptions:nil channelId:channelId handleNotificationOpened:^(CPNotificationOpenedResult *result) {
        if (!RCTCleverPush.sharedInstance.didStartObserving) {
             coldStartCPNotificationOpenedResult = result;
        } else {
             [self handleNotificationOpened:[self stringifyNotificationOpenedResult:result]];
        }
  }];
}

- (void)handleNotificationOpened:(NSString *)result {
    NSDictionary *json = [self jsonObjectWithString:result];
    
    if (json) {
        [self sendEvent:CPEventString(NotificationOpened) withBody:json];
    }
}

- (void)handleSubscribed:(NSString *)subscriptionId {
    NSDictionary* result = [[NSDictionary alloc] initWithObjectsAndKeys:
     subscriptionId, @"id",
     nil];

    [self sendEvent:CPEventString(Subscribed) withBody:result];
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

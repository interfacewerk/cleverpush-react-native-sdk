#import "RCTCleverPushEventEmitter.h"
#if __has_include(<CleverPush/CleverPush.h>)
#import <CleverPush/CleverPush.h>
#else
#import "CleverPush.h"
#endif

#import "RCTCleverPush.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"


@implementation RCTCleverPushEventEmitter {
    BOOL hasListeners;
}

static BOOL _didStartObserving = false;

+ (BOOL)hasSetBridge {
    return _didStartObserving;
}

+(BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(RCTCleverPush)

-(instancetype)init {
    if (self = [super init]) {
        NSLog(@"CleverPush: Initialized RCTCleverPushEventEmitter");
        
        for (NSString *eventName in [self supportedEvents])
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emitEvent:) name:eventName object:nil];
    }
    
    return self;
}

-(void)startObserving {
    hasListeners = true;
    NSLog(@"CleverPush: RCTCleverPushEventEmitter did start observing");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSetBridge" object:nil];
    
    _didStartObserving = true;
}

-(void)stopObserving {
    hasListeners = false;
    NSLog(@"CleverPush: RCTCleverPushEventEmitter did stop observing");
}

-(NSArray<NSString *> *)supportedEvents {
    NSMutableArray *events = [NSMutableArray new];
    
    for (int i = 0; i < CPNotificationEventTypesArray.count; i++)
        [events addObject:CPEventString(i)];
    
    return events;
}

- (void)emitEvent:(NSNotification *)notification {
    if (!hasListeners) {
        NSLog(@"CleverPush: Attempted to send an event (%@) when no listeners were set.", notification.name);
        return;
    }
    
    [self sendEventWithName:notification.name body:notification.userInfo];
}

+ (void)sendEventWithName:(NSString *)name withBody:(NSDictionary *)body {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:body];
}

RCT_EXPORT_METHOD(init:(NSString *)channelId) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RCTCleverPush sharedInstance] init:channelId];
    });
}

RCT_EXPORT_METHOD(getAvailableTags:(RCTResponseSenderBlock)callback) {
    NSArray* channelTags = [CleverPush getAvailableTags];
    callback(@[[NSNull null], channelTags]);
}

RCT_EXPORT_METHOD(getAvailableAttributes:(RCTResponseSenderBlock)callback) {
    NSDictionary* customAttributes = [CleverPush getAvailableAttributes];
    callback(@[[NSNull null], customAttributes]);
}

RCT_EXPORT_METHOD(getSubscriptionTags:(RCTResponseSenderBlock)callback) {
    NSArray* subscriptionTags = [CleverPush getSubscriptionTags];
    callback(@[[NSNull null], subscriptionTags]);
}

RCT_EXPORT_METHOD(getSubscriptionAttributes:(RCTResponseSenderBlock)callback) {
    NSDictionary* subscriptionAttributes = [CleverPush getSubscriptionAttributes];
    callback(@[[NSNull null], subscriptionAttributes]);
}

RCT_EXPORT_METHOD(getSubscriptionAttribute:(NSString *)attributeId callback:(RCTResponseSenderBlock)callback) {
    NSString* attributeValue = [CleverPush getSubscriptionAttribute:attributeId];
    callback(@[[NSNull null], attributeValue]);
}

RCT_EXPORT_METHOD(hasSubscriptionTag:(NSString *)tagId callback:(RCTResponseSenderBlock)callback) {
        bool hasTag = [CleverPush hasSubscriptionTag:tagId];
        callback(@[[NSNull null], hasTag]);
}

RCT_EXPORT_METHOD(addSubscriptionTag:(NSString *)tagId) {
    [CleverPush addSubscriptionTag:tagId];
}

RCT_EXPORT_METHOD(removeSubscriptionTag:(NSString *)tagId) {
    [CleverPush removeSubscriptionTag:tagId];
}

RCT_EXPORT_METHOD(setSubscriptionAttribute:(NSString *)attributeId value:(NSString*)value) {
    [CleverPush setSubscriptionAttribute:attributeId value:value];
}

@end

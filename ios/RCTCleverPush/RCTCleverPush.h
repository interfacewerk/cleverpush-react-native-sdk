
#if __has_include(<CleverPush/CleverPush.h>)
#import <CleverPush/CleverPush.h>
#else
#import "CleverPush.h"
#endif

#define INIT_DEPRECATION_NOTICE "Objective-C Initialization of the CleverPush SDK has been deprecated. Use JavaScript init instead."

@interface RCTCleverPush : NSObject <CPSubscriptionObserver>

+ (RCTCleverPush *) sharedInstance;

@property (nonatomic) BOOL didStartObserving;

- (void)configureWithChannelId:(NSString *)channelId;

@end

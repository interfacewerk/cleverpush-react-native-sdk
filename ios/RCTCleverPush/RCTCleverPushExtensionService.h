#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface RCTCleverPushExtensionService : NSObject

+ (void)serviceExtensionTimeWillExpireRequest:(UNNotificationRequest * _Nonnull)request withMutableNotificationContent:(UNMutableNotificationContent * _Nullable)content;
+ (void)didReceiveNotificationRequest:(UNNotificationRequest * _Nonnull)request withContent:(UNMutableNotificationContent * _Nullable)content;

@end

#import "PatchManager.h"
#import "DeviceInfo.h"
#import "CompatibilityChecker.h"

@implementation PatchManager
+ (instancetype)sharedManager {
    static PatchManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[PatchManager alloc] init]; });
    return manager;
}
- (void)evaluateWithCompletion:(void (^)(NSString *message))completion {
    DeviceInfo *info = [DeviceInfo currentDeviceInfo];
    NSString *range = [CompatibilityChecker summaryForOSVersion:info.osVersion];
    NSString *message = [NSString stringWithFormat:
        @"Device check complete. %@.\n\nNo verified exploit backend is integrated, so hurr1c4ne has not activated a jailbreak.", range];
    dispatch_async(dispatch_get_main_queue(), ^{ if (completion) completion(message); });
}
@end

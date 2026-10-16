#import "CompatibilityChecker.h"
@implementation CompatibilityChecker
+ (NSString *)summaryForOSVersion:(NSString *)version {
    if (version.length == 0) return @"Unknown — backend unverified";
    NSOperatingSystemVersion target = NSProcessInfo.processInfo.operatingSystemVersion;
    // Research target range only; this does not indicate exploitability.
    BOOL inRange = (target.majorVersion == 26) ||
                   (target.majorVersion == 27 && target.minorVersion == 0);
    return inRange ? @"Research target — backend unverified"
                   : @"Outside initial target range — backend unverified";
}
@end

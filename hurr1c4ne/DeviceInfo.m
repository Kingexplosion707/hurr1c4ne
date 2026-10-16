#import "DeviceInfo.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@implementation DeviceInfo
+ (instancetype)currentDeviceInfo {
    DeviceInfo *info = [[DeviceInfo alloc] init];
    struct utsname systemInfo;
    uname(&systemInfo);
    info->_modelIdentifier = [NSString stringWithUTF8String:systemInfo.machine] ?: @"Unknown";
    info->_osVersion = UIDevice.currentDevice.systemVersion ?: @"Unknown";
    NSString *build = @"Unavailable";
    NSDictionary *versionInfo = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    if ([versionInfo[@"ProductBuildVersion"] isKindOfClass:NSString.class]) {
        build = versionInfo[@"ProductBuildVersion"];
    }
    info->_osBuild = build;
    return info;
}
@end

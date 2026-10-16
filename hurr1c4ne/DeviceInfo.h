#import <Foundation/Foundation.h>
@interface DeviceInfo : NSObject
@property (nonatomic, copy, readonly) NSString *modelIdentifier;
@property (nonatomic, copy, readonly) NSString *osVersion;
@property (nonatomic, copy, readonly) NSString *osBuild;
+ (instancetype)currentDeviceInfo;
@end

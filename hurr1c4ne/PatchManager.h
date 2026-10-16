#import <Foundation/Foundation.h>
@interface PatchManager : NSObject
+ (instancetype)sharedManager;
- (void)evaluateWithCompletion:(void (^)(NSString *message))completion;
@end

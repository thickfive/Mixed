#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ObjcClass : NSObject
/// Objc method to call in Swift
+ (void)callInSwift;
/// Objc method calls Swift method
+ (void)callSwift;
@end
NS_ASSUME_NONNULL_END

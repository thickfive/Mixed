#import "ObjcClass.h"
#import <LibExample/LibExample-swift.h>

@implementation ObjcClass

+ (void)callInSwift {
    NSLog(@"%@ %s", self, __FUNCTION__);
}

+ (void)callSwift {
    [SwiftClass callInObjc];
}

@end

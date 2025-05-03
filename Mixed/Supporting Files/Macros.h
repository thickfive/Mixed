//
//  Macros.h
//  Mixed
//
//  Created by vvii on 2024/7/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Macros : NSObject
+ (void)test;
@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface ObjcAutorelease : NSObject
{
    char *buffer;
}
+ (void)test;
@end

@implementation ObjcAutorelease

- (instancetype)init {
    if (self = [super init]) {
        int size = 10 * 1024 * 1024;
        buffer = (char *)malloc(size);
        for (int i = 0; i < size; i++) {
            buffer[i] = 0; // 触发真正的内存占用
        }
    }
    return self;
}

- (void)dealloc {
    free(buffer);
    NSLog(@"[dealloc] %@", self);
}

+ (void)test {
    // 立即释放, 不需要 autoreleasepool
    for (int i = 0; i < 10; i++) {
        NSLog(@">>> loop start %d", i);
        // ObjcAutorelease *obj = [ObjcAutorelease new];
        NSLog(@"<<< loop end %d", i);
    }
                                    
    // OC 内存峰值不会过高, 同样的代码用 Swift 反而需要 autoreleasepool, 无法解释
    // 总之, 在需要的时候加 autoreleasepool, 至于什么时候需要, 看情况
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    for (int i = 0; i < 10; i++) {
        NSLog(@">>> loop start %d", i);
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSLog(@"<<< loop end %zd", data.length);
        sleep(1);
    }
}

@end
NS_ASSUME_NONNULL_END

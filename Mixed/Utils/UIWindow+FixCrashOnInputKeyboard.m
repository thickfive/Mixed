
#import "UIWindow+FixCrashOnInputKeyboard.h"
#import <objc/runtime.h>


@implementation UIWindow (FixCrashOnInputKeyboard)


+ (void)load
{
    // float os = [UIDevice currentDevice].systemVersion.floatValue;
    // if (os >= 16.0 && os < 17.0) {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("UIWindow");
        SEL originalSelector = @selector(sendEvent:);
        SEL swizzledSelector = @selector(sendEventEx:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
        
    // }
}

- (void)sendEventEx:(UIEvent *)event {
    if ([UIWindow isSendEventToDealloctingObject:event]) {
        return;
    }
    [self sendEventEx: event];
}

#pragma mark - check if sending Event to deallocating object
+ (BOOL) isSendEventToDealloctingObject:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        for (UITouch *touch in event.allTouches) {
            NSString *windowName = NSStringFromClass([touch.window class]);
            if ([windowName isEqualToString:@"UIRemoteKeyboardWindow"]) {
                UIView* view = touch.view;
                UIResponder *arg2 = view.nextResponder;
                NSString* responderClassName = NSStringFromClass([arg2 class]);
                if ([responderClassName isEqualToString:@"_UIRemoteInputViewController"]) {
                    bool isDeallocating = false;

                    // Use 'performSelector' when u are develop a App-Store App.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    SEL sel = NSSelectorFromString(@"_isDeallocating");
                    isDeallocating = [arg2 respondsToSelector:sel] && [arg2 performSelector:sel];
            #pragma clang diagnostic pop

                    if (isDeallocating) {
                        NSLog(@"UIWindow - BingGo a deallocating object ...");
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

// iOS 16 之后已经没办法通过常规手段拿到 UIRemoteKeyboardWindow 了
// 上面的代码是用来修复 iOS 16 键盘崩溃的, 它刚好可以遍历到 UIRemoteKeyboardWindow
// 其他代码可以不要, 可能涉及到私有 API
+ (void)addSubviewsOverKeyboardWindow:(UIWindow *)window {
    if (window.subviews.count > 0) {
        // UIInputSetContainerView
        UIView *containerView = window.subviews[0];
        
        // UIInputSetHostView
        if (containerView.subviews.count > 0) {
            UIView *hostView = containerView.subviews[0];
            
            BOOL isAdded = NO;
            for (UIView *view in hostView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    isAdded = YES;
                }
            }
            
            if (!isAdded) {
                UILabel *textLabel = [UILabel new];
                textLabel.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8];
                textLabel.font = [UIFont systemFontOfSize:12];
                textLabel.textColor = [UIColor whiteColor];
                textLabel.textAlignment = NSTextAlignmentCenter;
                textLabel.text = @"长按🌐切换到XX输入法";
                [textLabel sizeToFit];
                textLabel.layer.cornerRadius = 20;
                textLabel.layer.masksToBounds = YES;
                textLabel.frame = CGRectMake(20, hostView.bounds.size.height - 120, textLabel.bounds.size.width + 20, 40);
                [hostView addSubview:textLabel];
            }
        }
    }
}

@end


// #pragma mark - UIApplication (SendEvent)
// @interface UIApplication (SendEvent)
// 
// @end
// 
// @implementation UIApplication (SendEvent)
// 
// + (void)load {
//     static dispatch_once_t onceToken;
//     dispatch_once(&onceToken, ^{
//         Class class = objc_getClass("UIApplication");
//         SEL originalSelector = @selector(sendEvent:);
//         SEL swizzledSelector = @selector(sendEventEx:);
//         Method originalMethod = class_getInstanceMethod(class, originalSelector);
//         Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//         method_exchangeImplementations(originalMethod, swizzledMethod);
//     });
// }
// 
// - (void)sendEventEx:(UIEvent *)event {
//     NSLog(@"-[UIApplication sendEvent:]");
//     [self sendEventEx: event];
// }
// 
// @end

#pragma mark - UIView (KeyboardWindow)
@interface UIView (KeyboardWindow)

@end

@implementation UIView (KeyboardWindow)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("UIView");
        SEL originalSelector = @selector(initWithFrame:);
        SEL swizzledSelector = @selector(initWithFrameEx:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)initWithFrameEx:(CGRect)frame {
    if ([NSStringFromClass(self.class) isEqualToString:@"UIRemoteKeyboardWindow"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addSubviewsOverKeyboardWindow:(UIWindow *)self];
        });
    }
    [self initWithFrameEx:frame];
}

- (void)addSubviewsOverKeyboardWindow:(UIWindow *)window {
    if (window.subviews.count > 0) {
        // UIInputSetContainerView
        UIView *containerView = window.subviews[0];
        
        UILabel *textLabel = [UILabel new];
        textLabel.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8];
        textLabel.font = [UIFont systemFontOfSize:12];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = @"长按🌐切换到XX输入法";
        [textLabel sizeToFit];
        textLabel.layer.cornerRadius = 20;
        textLabel.layer.masksToBounds = YES;
        textLabel.frame = CGRectMake(20, containerView.bounds.size.height - 120, textLabel.bounds.size.width + 20, 40);
        [containerView addSubview:textLabel];
    }
}

@end


#import "UIWindow+FixCrashOnInputKeyboard.h"
#import <objc/runtime.h>


@implementation UIWindow (FixCrashOnInputKeyboard)


+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("UIWindow");
        SEL originalSelector = @selector(sendEvent:);
        SEL swizzledSelector = @selector(sendEventEx:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
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


@end


#pragma mark - UIWindow (KeyboardWindow)

/// iOS 16 之后获取 UIRemoteKeyboardWindow 的方法
/// 1. 交换 -[UIView initWithFrame:], 判断类型是否为 UIRemoteKeyboardWindow
/// 2. 交换 -[UIWindow _initWithFrame:debugName:windowScene:], 缩小影响范围. 可以通过断点 bt 打印调用堆栈, 查看真正的 UIWindow init 方法
@interface UIWindow (KeyboardWindow)

@end

@implementation UIWindow (KeyboardWindow)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL originalSelector = @selector(_initWithFrame:debugName:windowScene:);
    #pragma clang diagnostic pop
        SEL swizzledSelector = @selector(_initWithFrameEx:debugName:windowScene:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL isAdded = class_addMethod(class,
                                       originalSelector,
                                       method_getImplementation(swizzledMethod),
                                       method_getTypeEncoding(swizzledMethod));
        if (isAdded) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (instancetype)_initWithFrameEx:(CGRect)frame debugName:(NSString *)debugName windowScene:(UIWindowScene *)windowScene {
    if ([NSStringFromClass(self.class) isEqualToString:@"UIRemoteKeyboardWindow"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addSubviewsOverKeyboardWindow:(UIWindow *)self];
        });
    }
    return [self _initWithFrameEx:frame debugName:debugName windowScene:windowScene];
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

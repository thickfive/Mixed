//
//  Macros.m
//  Mixed
//
//  Created by vvii on 2024/7/12.
//

#import "Macros.h"

// __c_stringify(a\bc) => a?c
#define __c_stringify(a) (# a)

// __c_stringify2(a\bc) => "a\bc"
#define __c_stringify2(a) __c_stringify(# a)
 
// a##b => ab => "ab", ## 连接参数
#define __c_stringify_concat(a,b) __c_stringify(a##b)

// (condition, path) => path, 逗号表达式, 判断nil对象类型是否有对应的属性
#define MZKeyPath(OBJ, PATH) \
(((void)(NO && ((void)(((typeof(OBJ))nil).PATH), NO)), @# PATH))

#ifndef REGEXP
# define _regexp_stringify(x)       #x
# define _regexp_stringify2(x)      _regexp_stringify(x)
# define _regexp(...)               ({ const char *str = _regexp_stringify2(# __VA_ARGS__); const size_t length = strlen(str); [[NSString alloc] initWithBytes:str + 1 length:length - 2 encoding:NSUTF8StringEncoding]; })
# define REGEXP(...)                [NSRegularExpression regularExpressionWithPattern:_regexp(__VA_ARGS__) options:0 error:NULL]
#endif

@implementation Macros

+ (void)test {
    // \+(a-z) 有很多都是无法通过编译的写法, 比如 \u
    
    // # 字符串化, 不能单纯地解释为加"", 有可能加上之后无法编译, 就需要转义
    // 第一次没有加上引号
    // 61 08 2f 63
    // a     /  c
    printf("1 = %s \n", __c_stringify(a\b/c));
    
    // 第二次加上引号和反斜杠
    // 22 61 5c 62 2f 63 22
    // "  a  \  b  /  c  "
    printf("2 = %s \n", __c_stringify2(a\b/c));
    
    // ^1\d{10}$
    NSLog(@"3 = %@ \n", REGEXP(^1\d{10}$));
    
    NSString *path = MZKeyPath(NSString *, lowercaseString.uppercaseString.length);
    NSLog(@"key path = %@", path);
}

@end

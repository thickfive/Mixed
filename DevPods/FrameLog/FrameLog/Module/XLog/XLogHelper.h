//
//  XLogHelper.h
//  Pods
//
//  Created by 吴迢荣 on 2021/12/13.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XLogLevel) {
    XLogLevelAll = 0,
    XLogLevelVerbose = 0,
    XLogLevelDebug,    // Detailed information on the flow through the system.
    XLogLevelInfo,     // Interesting runtime events (startup/shutdown), should be conservative and keep to a minimum.
    XLogLevelWarn,     // Other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
    XLogLevelError,    // Other runtime errors or unexpected conditions.
    XLogLevelFatal,    // Severe errors that cause premature termination.
    XLogLevelNone,     // Special level used to disable all log messages.
};

#define LogInternal(level, module, file, line, func, format, ...) \
do { \
    if ([XLogHelper shouldLog:level]) { \
        NSString *aMessage = [NSString stringWithFormat:format, ##__VA_ARGS__, nil]; \
        [XLogHelper logWithLevel:level moduleName:module fileName:file lineNumber:line funcName:func message:aMessage]; \
    } \
} while(0)

#define __FILENAME__ (strrchr(__FILE__,'/')+1)

/// 这几个宏调用前必须先调用LogHelper的initXLog:方法设置log配置
#define XLOG_ERROR(module, format, ...) LogInternal(XLogLevelError, module, __FILENAME__, __LINE__, __FUNCTION__,  format, ##__VA_ARGS__)
#define XLOG_WARNING(module, format, ...) LogInternal(XLogLevelWarn, module, __FILENAME__, __LINE__, __FUNCTION__,  format, ##__VA_ARGS__)
#define XLOG_INFO(module, format, ...) LogInternal(XLogLevelInfo, module, __FILENAME__, __LINE__, __FUNCTION__,  format, ##__VA_ARGS__)
#define XLOG_DEBUG(module, format, ...) LogInternal(XLogLevelDebug, module, __FILENAME__, __LINE__, __FUNCTION__,  format, ##__VA_ARGS__)

@interface XLogHelper : NSObject

+ (instancetype)sharedHelper;

- (void)initXLog:(XLogLevel)debugLevel
          releaseLevel:(XLogLevel)releaseLevel
            path: (NSString*)path
          prefix: (NSString*)prefix
          pubKey: (NSString*)pubKey;

/// 获取本地日志文件路径列表
- (NSArray *)getLogFilePathList;

/// 清空本地日志
- (void)clearLocalLogFile;

/*! 日志产生后，会被写入逻辑内存，在应用即将被回收时，需要调用该方法，保存数据到缓存目录
 *  在应用即将被回收时调用
 *  - (void)applicationWillTerminate:(UIApplication *)application {
 *      [LogHelper logAppenderClose];
 *  }
 */
+ (void)logAppenderClose;

/// 上传前刷新缓存表，防止数据更新不及时。（不调用会存在日志丢失的情况）
+ (void)logAppenderFlush;

/// 写入log
+ (void)logWithLevel:(XLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
             message:(NSString *)message;

+ (void)logWithLevel:(XLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
              format:(NSString *)format, ...;

+ (BOOL)shouldLog:(XLogLevel)level;

@end

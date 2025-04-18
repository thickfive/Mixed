//
//  XLogHelper.mm
//  FrameLog
//
//  Created by 吴迢荣 on 2021/12/13.
//

#import "XLogHelper.h"

#import <sys/xattr.h>
#import <mars/xlog/xloggerbase.h>
#import <mars/xlog/xlogger.h>
#import <mars/xlog/appender.h>

static NSUInteger g_processID = 0;

@interface XLogHelper ()

/// 日志本地存储目录
@property (nonatomic, retain) NSString* path;

@end

@implementation XLogHelper

+ (instancetype)sharedHelper {
    
    static id singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[[self class] alloc] init];
    });
    return singleton;
}

#pragma mark - 日志配置

- (void)initXLog:(XLogLevel)debugLevel releaseLevel:(XLogLevel)releaseLevel path:(NSString *)path prefix:(NSString*)prefix pubKey:(NSString*)pubKey {
    self.path = path;
    const char *logPath = [path UTF8String];
    const char *logPubKey = pubKey ? [pubKey UTF8String] : "";
    const char *logPrefix = [prefix UTF8String];
        
    NSString* attrNameStr = [NSString stringWithFormat: @"%@.%@", prefix, @"backup"];
    const char* attrName = [attrNameStr UTF8String];
    u_int8_t attrValue = 1;
    setxattr(logPath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    // init xlog
    #if DEBUG

    xlogger_SetLevel((TLogLevel)debugLevel);
    mars::xlog::appender_set_console_log(true);
    #else
   
    xlogger_SetLevel((TLogLevel)releaseLevel);
    mars::xlog::appender_set_console_log(false);
    #endif
    
    mars::xlog::XLogConfig config;
    config.mode_ = mars::xlog::kAppenderAsync;
    config.logdir_ = logPath;
    config.nameprefix_ = logPrefix;
    config.pub_key_ = logPubKey;
    config.compress_mode_ = mars::xlog::kZlib;
    config.cachedir_ = "";
    config.cache_days_ = 0;
    mars::xlog::appender_open(config);
    
    XLOG_DEBUG("XLog", @"XLog配置完成，本地日志文件地址：%@", path);
}

- (NSArray *)getLogFilePathList {
    NSMutableArray *logArr = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = self.path;
    if ([fileManager fileExistsAtPath:path]) {
        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
        for (NSString *fileName in enumerator) {
            if ([fileName hasSuffix:@".xlog"]) {
                NSString *enumeratorPath = [NSString pathWithComponents:@[path, fileName]];
                [logArr addObject:enumeratorPath];
            }
        }
    }
    return logArr;
}

- (void)clearLocalLogFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = self.path;
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
    for (NSString *fileName in enumerator) {
        if ([fileName hasSuffix:@".xlog"]) {
            NSString *logFilePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:logFilePath error:nil];
        }
    }
}


+ (void)logAppenderClose {
    mars::xlog::appender_close();
}

+(void)logAppenderFlush {
    mars::xlog::appender_flush_sync();
}

#pragma mark - 日志打印相关

+ (void)logWithLevel:(XLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
             message:(NSString *)message {
    XLoggerInfo info;
    info.level = (TLogLevel)logLevel;
    info.tag = moduleName;
#if DEBUG
    info.filename = "";
    info.func_name = "";
    info.line = 0;
#else
    info.filename = fileName;
    info.func_name = funcName;
    info.line = lineNumber;
#endif
    
    gettimeofday(&info.timeval, NULL);
    info.tid = (uintptr_t)[NSThread currentThread];
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = g_processID;
    xlogger_Write(&info, message.UTF8String);
}

+ (void)logWithLevel:(XLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
              format:(NSString *)format, ... {
    if ([self shouldLog:logLevel]) {
        va_list argList;
        va_start(argList, format);
        NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
        [self logWithLevel:logLevel moduleName:moduleName fileName:fileName lineNumber:lineNumber funcName:funcName message:message];
        va_end(argList);
    }
}

+ (BOOL)shouldLog:(XLogLevel)level {
    return (TLogLevel)level >= xlogger_Level();
}

@end


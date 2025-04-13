//
//  LogMessage.m
//  Mixed
//
//  Created by vvii on 2024/10/3.
//

#import "LogMessage.h"
#import <Mixed-Swift.h>

void ijk_log_message(int level, char *TAG, const char *restrict format, ...) {
    va_list args;
    va_start(args, format);
    char *formated_string = malloc(1024); // 长度与 sdk 内部保持一致
    vsnprintf(formated_string, 1024, format, args);
    NSString *message = [NSString stringWithFormat:@"[🟩][%d][%s] %s", level, TAG, formated_string];
    // NSLog(@"%@", message); // 根据需要写入日志
    [Log logMessage:message];
    free(formated_string);
    va_end(args);
}

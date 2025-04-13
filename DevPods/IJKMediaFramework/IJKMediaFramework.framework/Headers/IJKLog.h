//
//  IJKLog.h
//  IJKMediaPlayer
//
//  Created by vvii on 2024/10/3.
//  Copyright © 2024 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdarg.h>

extern void ijk_log_message(int level, char *TAG, const char *restrict format, ...);

extern void IJKLog(NSString *format, ...);



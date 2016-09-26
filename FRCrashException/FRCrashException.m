//
//  FRCrashException.m
//  FRCrashException
//
//  Created by sonny on 16/9/22.
//  Copyright © 2016年 sonny. All rights reserved.
//

#import "FRCrashException.h"

// ===========================================================================================

NSString *const FRRequest_Method_Version = @"1.1.0";
NSString *const FRUserId = @"000001";





@interface TmpObject : NSObject

+ (NSString *)nowTime;
+ (BOOL)writeLocalFile:(NSString *)str;

@end

@implementation TmpObject

+ (NSString *)nowTime {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *t = [dateformatter stringFromDate:[NSDate date]];
    return t;
}

+ (BOOL)writeLocalFile:(NSString *)str {
    //写错误日志
    NSDate *date = [NSDate date];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    NSString *savePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"crashLog"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [formater setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *f = [NSString stringWithFormat:@"%@.text",[formater stringFromDate:date]];
    savePath = [savePath stringByAppendingPathComponent:f];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
    }
    BOOL value = [str writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    return value;
}


@end



// ===========================================================================================

void crashExceptionHandler(NSException *exception);
void signalHandler(int sig, siginfo_t *info, void *context);

void crashExceptionHandler(NSException *exception) {
    
    // 时间
    NSString *time = [TmpObject nowTime];
    
    // 最后一次网络请求和返回的数据
    NSString *lastRequest = @"最后一次网络请求 lastRequest";
    NSString *lastResponse = @"最后一次网络返回 lastResponse";
    
    //最后一次停留页面
    NSString *lastView = @"最后一个页面 lastViewController";
    
    NSString *systemVersion = [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
    NSString *model = [[UIDevice currentDevice] model];
    
    NSString *exceptionName = [exception name];
    NSString *exceptionReason = [exception reason];
    NSArray *exceptionCallStack = [exception callStackSymbols];
    
    NSString *fileString = [NSString stringWithFormat:
@"time                === %@;\n\
methodVersion       === %@;\n\
userId              === %@;\n\
systemVersion       === %@;\n\
model               === %@;\n\
lastViewController  === %@;\n\n\
exceptionName       === %@;\n\n\
exceptionReason     === \n %@;\n\n\
exceptionCallStack  === \n%@;\n\n\
lastRequest         === \n %@;\n\n\
lastResponse        === \n %@;\n",
                            time,
                            FRRequest_Method_Version,
                            FRUserId,
                            systemVersion,
                            model,
                            lastView,
                            exceptionName,
                            exceptionReason,
                            [exceptionCallStack componentsJoinedByString:@"\n"],
                            lastRequest,
                            lastResponse];
    //写错误日志
    [TmpObject writeLocalFile:fileString];
    NSLog(@"\n <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 异常崩溃日志 打印开始 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n%@\n\
            >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 异常崩溃日志 打印结束 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",fileString);
}


void signalHandler(int sig, siginfo_t *info, void *context) {
    
    NSException *e = [NSException exceptionWithName:@"signal exception"
                                             reason:[NSString stringWithFormat:@"signal %d", sig]
                                           userInfo:nil];
    crashExceptionHandler(e);
}

@implementation FRCrashException

static FRCrashException *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (instancetype)copyWithZone:(struct _NSZone *)zone {
    return instance;
}

+ (void)setCrashExceptionHandler {
    
    NSSetUncaughtExceptionHandler(&crashExceptionHandler);
    struct sigaction sigAction;
    sigAction.sa_sigaction = signalHandler;
    sigAction.sa_flags = SA_SIGINFO;
    sigemptyset(&sigAction.sa_mask);
    sigaction(SIGQUIT, &sigAction, NULL);
    sigaction(SIGILL, &sigAction, NULL);
    sigaction(SIGTRAP, &sigAction, NULL);
    sigaction(SIGABRT, &sigAction, NULL);
    sigaction(SIGEMT, &sigAction, NULL);
    sigaction(SIGFPE, &sigAction, NULL);
    sigaction(SIGBUS, &sigAction, NULL);
    sigaction(SIGSEGV, &sigAction, NULL);
    sigaction(SIGSYS, &sigAction, NULL);
    sigaction(SIGPIPE, &sigAction, NULL);
    sigaction(SIGALRM, &sigAction, NULL);
    sigaction(SIGXCPU, &sigAction, NULL);
    sigaction(SIGXFSZ, &sigAction, NULL);
}

+ (NSUncaughtExceptionHandler *)crashExceptionHandler {
    return NSGetUncaughtExceptionHandler();
}

@end

//
//  FRCrashException.h
//  FRCrashException
//
//  Created by sonny on 16/9/22.
//  Copyright © 2016年 sonny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern void signalHandler(int sig, siginfo_t *info, void *context);

@interface FRCrashException : NSObject

+ (instancetype)sharedInstance;

+ (void)setCrashExceptionHandler;
+ (NSUncaughtExceptionHandler *)crashExceptionHandler;

@end

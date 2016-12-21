//
//  PLCrashBuilder.h
//  PRIS
//
//  Created by suns on 12-11-8.
//
//

#import <Foundation/Foundation.h>

@interface PLCrashBuilder : NSObject


NSString *parseSignalInfo(int signal, siginfo_t *siginfo);

@end

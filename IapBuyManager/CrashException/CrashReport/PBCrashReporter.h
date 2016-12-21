//
//  PBCrashReporter.h
//  PRIS
//
//  Created by suns on 12-11-7.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PBCrashReporter : NSObject
<UIAlertViewDelegate>

+ (NSArray *)backtrace;

+ (PBCrashReporter *)sharedInstance;

- (void)saveReportIfAllowed:(NSString *)aReportString isException:(BOOL)aIsException;  //  如果此时可以允许保存报告，则保存

- (void)askAndSendIfNeeded; //  如果有需要发送的日志，则发送

@end


@interface PBCrashReporter ()

//  是否允许发送报告：在保存报告、发送报告过程中，将要terminate时，不允许保存
@property (atomic, assign) BOOL allowedSaveReport;


@end

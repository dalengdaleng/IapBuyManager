//
//  PBCrashReporter.m
//  PRIS
//
//  Created by suns on 12-11-7.
//
//

#include <execinfo.h>

#import "PLCrashSignalHandler.h"

#import "PBCrashReporter.h"
//#import "ZipArchive.h"
#import "PLCrashBuilder.h"
#import "Reachability.h"
#import "DeviceInfo.h"
#import "SSZipArchive.h"
//#import "FeedbackTask.h"
//#import "SVProgressHUD.h"
#pragma mark - 静态函数等




/**
 * @internal
 *
 * Signal handler callback.
 */
static void signal_handler_callback (int signal, siginfo_t *info, ucontext_t *uap, void *context) {
    //  线程
    //  signal
    NSString *signalString = parseSignalInfo(signal, info);
    NSArray *arr = [PBCrashReporter backtrace];
    NSString *str = [NSString stringWithFormat:@"sig:%@ \ntrack:%@", signalString, arr];
    [[PBCrashReporter sharedInstance] saveReportIfAllowed:str isException:NO];
}


#pragma mark - PBCrashReporter

@interface PBCrashReporter ()

//  是否需要发送报告：如果最新保存了报告，则设置为需要发送报告；如果用户最近拒绝发送，则设置为不需要发送报告
@property (atomic, readonly) BOOL needSend, isException;
- (void)setNeedSend:(BOOL)aNeedSend isException:(BOOL)aIsException;

- (BOOL)saveReport:(NSString *)aReportString;

- (void)asyncSendReport;
@property (nonatomic, assign) BOOL needResultTips;

@end

@implementation PBCrashReporter

#pragma mark - 公开接口

+ (NSArray *)backtrace

{
    
    void* callstack[128];
    
    int frames = backtrace(callstack, 128);
    
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);	 
    
    return backtrace;
    
}

#pragma mark - 生命周期

- (id)init
{
    self = [super init];
    if (self) {
        [self setAllowedSaveReport:YES];
        
        [[PLCrashSignalHandler sharedHandler] registerHandlerWithCallback: &signal_handler_callback context: &signal_handler_callback error: nil];
    }
    
    return self;
}

//  公开接口

+ (PBCrashReporter *)sharedInstance
{
    static PBCrashReporter *sCrashReporter = nil;
    
    if (sCrashReporter == nil) {
        sCrashReporter = [[PBCrashReporter alloc] init];
    }
    
    return sCrashReporter;
}

- (void)saveReportIfAllowed:(NSString *)aReportString isException:(BOOL)aIsException
{
    if (self.allowedSaveReport) {
        if ([self saveReport:aReportString]) {
            //  保存成功
            [self setNeedSend:YES isException:aIsException];
        }
#ifdef USING_TEST_SERVER
        
        NSString *urlstring = @"http://192.168.144.13/yuedu/iphonecrash.html";
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstring]];
#endif
    }
}

/***************************************
 
 处理逻辑：
 
 如果需要发送：
 
    如果有网络，判断是否有堆栈
 
        如果有堆栈：询问是否发送
 
        如果没有堆栈，如果是wifi，悄悄发送
 
    如果没有网络：重置
 
 
 
 **************************************/

- (void)askAndSendIfNeeded
{
    if (self.needSend) {
        [self setNeedSend:NO isException:self.isException];
        
        //  有网络
        if ([[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) {
            //  有堆栈
            if (self.isException) {
                //  询问后发送
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"程序从崩溃中恢复" message:@"发送错误日志能帮助我们改善产品" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送错误日志", nil];
                [av show];
            } else {
                //  没有堆栈
                //  wifi
                if ([[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) {
                    //  wifi下，悄悄发送
                    [self setNeedResultTips:NO];
                    [self performSelector:@selector(asyncSendReport) withObject:nil afterDelay:5.f];//  延时五秒再发送，等待autologin
                }
            }
        }
    } else {
        unsigned long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:[PBCrashReporter pathOfReportFile] error:nil].fileSize;
        if (fileSize > 50 * 1024) {
            [[NSFileManager defaultManager] removeItemAtPath:[PBCrashReporter pathOfReportFile] error:nil];
        }
    }
}

//  辅助函数

static NSString *kKeyForNeedSend = @"kKeyForNeedSend", *kKeyForIsException = @"kKeyForIsException";

- (void)setNeedSend:(BOOL)aNeedSend isException:(BOOL)aIsException
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:aNeedSend forKey:kKeyForNeedSend];
    [ud setBool:aIsException forKey:kKeyForIsException];
    [ud synchronize];
}

- (BOOL)needSend
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:kKeyForNeedSend];
}

- (BOOL)isException
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:kKeyForIsException];
}

+ (NSString *)pathOfReportFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"crash.txt"];
    return path;
}

- (BOOL)saveReport:(NSString *)aReportString
{
    BOOL success = NO;
    [self setAllowedSaveReport:NO];
    
    //  保存
    NSError *error = nil;
    NSString *newString = nil;
    NSString *oldString = @"";
    
    //  判断文件是否存在，如果已有文件则带上以前未发送的文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:[PBCrashReporter pathOfReportFile]]) {
        oldString = [NSString stringWithContentsOfFile:[PBCrashReporter pathOfReportFile] encoding:NSUTF8StringEncoding error:&error];
    }
    newString = [NSString stringWithFormat:@"%@ \n %@ \n %@", [NSDate date], aReportString, oldString.length > 0 ? oldString : @""];
    success = [newString writeToFile:[PBCrashReporter pathOfReportFile] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self setAllowedSaveReport:YES];
    return success;
}

- (void)asyncSendReport
{
    if (![[Reachability reachabilityForInternetConnection] isReachable]) {
        return;
    }
    [self setAllowedSaveReport:NO];
//    NSString *isException = @"[无堆栈]"; //4.8.6 去除value stored
//    if (self.isException) { //4.8.6 去除value stored
//        isException = @"[有堆栈]"; //4.8.6 去除value stored
//    }
    NSString *title = [NSString stringWithFormat:@"%@错误日志",[self logTitlePrefix]];
    NSString *contact = @"";
//    if(![gDataEngine isAnonymous])
//    {
//        account = [gDataEngine getUserId];
//    }
//    if(!contact.length && ![gDataEngine isAnonymous] && [gDataEngine snsUserInfo].urs!=nil)
//    {
//        contact = [gDataEngine snsUserInfo].urs;
//    }
    
    //  2、创建zip文件
    NSString *zipFileName = nil;
//	NSString* logFile1 = NELogFileDirectory();
//	NSString* logFile2 = PRISLogGetLastlogFilepath() ;

    NSString *logFileDirectory = [self logPath];//自己的log文件所在路径//NELogFileDirectory();
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:logFileDirectory];
    NSMutableArray *allFiles = [NSMutableArray array];
    for (NSString *fileName in enumerator) {
        [allFiles addObject:[logFileDirectory stringByAppendingPathComponent:fileName]];
    }
    
//    [allFiles addObject:[logFile1 stringByAppendingPathComponent:@"log.txt"]];
//	ret = [zip addFileToZip:logFile2 newname:@"log_last.txt"];  //  不发last的，防止log文件过大
//    [zip addFileToZip:[PBCrashReporter pathOfReportFile] newname:@"crash.txt"];
    [allFiles addObject:[PBCrashReporter pathOfReportFile]];
//	if( ![zip CloseZipFile2] )
//	{
//		zipFilePath = @"";
//	}
    
    if (allFiles.count > 0) {
        NSString *tmpPath = NSTemporaryDirectory();
        zipFileName = [tmpPath stringByAppendingString:@"log.zip"];
        if (![SSZipArchive createZipFileAtPath:zipFileName withFilesAtPaths:allFiles]) {
            zipFileName = nil;
        }
    }
    
    NSString *crashText = [NSString stringWithContentsOfFile:[PBCrashReporter pathOfReportFile] encoding:NSUTF8StringEncoding error:nil];
    if (crashText.length > 2500) {
        crashText = [crashText substringToIndex:1500];
    }
    if (crashText.length <= 0) {
        crashText = @"";
    }
    
    NSString *contentString = [NSString stringWithFormat:@"程序崩溃了\n%@", crashText];
    //  3、创建task
//    Task *task = [gDataEngine createCrashTask:title content:contentString filePath:zipFilePath contact:contact];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAsyncSendReportResult:) name:task.getTaskIdStr object:nil];
//    [gDataEngine asyncRunTask:task];
//    [task release];
    NSString *productName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    //自己提交给后台管理crash信息。
    
//    FeedbackTask *feedbackTask = [[FeedbackTask alloc] initWithProductName:productName
//                                                                 productId:82009011
//                                                                feedbackId:82008025
//                                                                  username:@"anonymous"
//                                                                     title:title
//                                                                   content:contentString
//                                                                  filePath:zipFileName
//                                                                   contact:contact
//                                                          deleteFileIfDone:YES
//                                                                  callback:^(NETaskResult *result, id context) {
//                                                                      if ([result isSuccess]) {
//                                                                          //  发送成功
//                                                                          //  删除crashreport？
//                                                                          if (self.needResultTips) {
//                                                                              [SVProgressHUD showSuccessWithStatus:@"提交成功"];
//                                                                          }
//                                                                      }
//                                                                      else if ([result isFail]) {
////                                                                          [SVProgressHUD showErrorWithStatus:@"提交失败"];
//                                                                      }
//                                                                      [self setAllowedSaveReport:YES];
//                                                                  }];
//    
//    [feedbackTask start];
}

//- (void)onAsyncSendReportResult:(NSNotification *)aNotification
//{
//    NSString *resultType = [aNotification.userInfo objectForKey:RESULTTYPE];
//    
//    if ([resultType isEqualToString:TASKSTATUS]) {
//        Task *task = [aNotification.userInfo objectForKey:TASK];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:task.getTaskIdStr object:nil];
//		NSNumber *errCode = (NSNumber *)[aNotification.userInfo objectForKey:RESULT];
//        
//		if ([errCode intValue] == 0)
//        {
//            //  发送成功
//            //  删除crashreport？
//            if (self.needResultTips) {
//				[OTToast showWithText:@"发送成功"];
//            }
//        } else {
//            //  发送失败
//        }
//        
//        
//        
//        [self setAllowedSaveReport:YES];
//    }
//}


#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        //  发送错误日志
        [self setNeedResultTips:YES];
        [self asyncSendReport];
    }
}

- (NSString *)logTitlePrefix
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *iosType = @"iphone";
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *displayName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSString *curBundleId = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    //    NSString *normalDisplayName = @"网易云阅读";
    NSString *normalBundleId = @"app的bundleid";//@"com.langhe.nebooks.urbanromance";
    
    NSString *extraInfo = @"";
    
    NSString *extraBundleInfo = @"";
    if([curBundleId rangeOfString:[normalBundleId stringByAppendingString:@"."]].location!=NSNotFound){
        extraBundleInfo = [curBundleId substringFromIndex:normalBundleId.length+1];
    }
    extraInfo = [NSString stringWithFormat:@"_%@_%@_%@_r",displayName,extraBundleInfo,[DeviceInfo platform]];
#ifdef USING_TEST_SERVER
    extraInfo = [extraInfo stringByAppendingString:@"_[测试]"];
#endif
#ifdef MID_APPSTORE
    extraInfo = @"";
#endif
    return [NSString stringWithFormat:@"%@%@%@",iosType,version,extraInfo];
}

- (NSString *)logPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryDir = [paths objectAtIndex:0];
    
    NSString *tempPath = [libraryDir stringByAppendingPathComponent:@"log.txt"];
    
    return tempPath;
}
@end

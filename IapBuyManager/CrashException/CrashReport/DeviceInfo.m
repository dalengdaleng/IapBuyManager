//
//  DeviceInfo.m
//  PRIS
//
//  Created by huangxiaowei on 10-12-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DeviceInfo.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <SystemConfiguration/CaptiveNetwork.h>
#import <sys/utsname.h>

@implementation DeviceInfo

//+ (BOOL)isNetworkAvailable
//{
//    JsmReachability* reachability = [JsmReachability reachabilityForInternetConnection];
//	JsmNetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
//	if (remoteHostStatus == JsmNotReachable)
//	{
//		return NO;
//	}
//	return YES;
//}

//+ (BOOL)isIpad
//{
//	static BOOL init = NO;
//	static BOOL onIpad = NO;
//	
//	if (!init)
//	{
//		NSString *model = [UIDevice currentDevice].model;
//		NSRange range = [model rangeOfString:@"IPAD" options:NSCaseInsensitiveSearch];
//		if (range.location != NSNotFound) {
//			onIpad = YES;
//		}
//		init = YES;
//	}
//	
//	return onIpad;
//}

+ (BOOL)isBuildForIPad
{
    BOOL isBuildIPad = NO;
#ifdef BUILD_FOR_IPAD        
    isBuildIPad = YES;
#else
    isBuildIPad = NO;
#endif
    return isBuildIPad;
}



+ (BOOL)isItouch
{
	static BOOL init = NO;
	static BOOL onItouch = NO;
	
	if (!init)
	{
		NSString *model = [UIDevice currentDevice].model;
		NSRange range = [model rangeOfString:@"TOUCH" options:NSCaseInsensitiveSearch];
		if (range.location != NSNotFound) {
			onItouch = YES;
		}
		init = YES;
	}
	
	return onItouch;
}


// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
+ (NSString *) macAddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

//+ (NSString *)macDeviceId
//{
//    NSString *uniqueIdentifier = nil;
//    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//    {
//        uniqueIdentifier = [DESettings getAppUid];
//    }
//    if (uniqueIdentifier == nil){
//        NSString *mac = [[DeviceInfo macAddress] lowercaseString];
//        uniqueIdentifier = [[Md5 encode:mac] lowercaseString];
//    }
//    
//    NSAssert([uniqueIdentifier length], @"device id is nil");
//    
//    return uniqueIdentifier;    
//}
//
//+ (NSString *)realMacDeviceId
//{
//    NSString *uniqueIdentifier = nil;
//
//    NSString *mac = [[DeviceInfo macAddress] lowercaseString];
//    uniqueIdentifier = [[Md5 encode:mac] lowercaseString];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
//        uniqueIdentifier = @"";
//    }
//    return uniqueIdentifier;
//}

+ (NSString *)platform
{
    
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);
    
    return platform;
    
}




+ (BOOL)isHighPerformance
{
    
    NSString *machine = [DeviceInfo platform];
    
    //iPhone
    if([machine compare:@"iPhone1,1"] == NSOrderedSame     // "iPhone1G GSM"
       || [machine compare:@"iPhone1,2"] == NSOrderedSame   // iPhone3G GSM"
       || [machine compare:@"iPhone2,1"] == NSOrderedSame  // "iPhone3GS GSM"
       )
//       || [machine compare:@"iPhone3,1"] == NSOrderedSame  // "iPhone4 GSM";
//       || [machine compare:@"iPhone3,2"] == NSOrderedSame  // "iPhone4 CDMAV";
//       || [machine compare:@"iPhone3,3"] == NSOrderedSame  // "iPhone4 CDMAS"
//       || [machine compare:@"iPhone4,1"] == NSOrderedSame  // "iPhone4S GSM"
//       || [machine compare:@"iPhone4,2"] == NSOrderedSame  // "iPhone4S CDMAV"
//       || [machine compare:@"iPhone4,3"] == NSOrderedSame  // "iPhone4S CDMAS"
//       || [machine compare:@"iPhone5,1"] == NSOrderedSame  // "iPhone5 GSM"
//       || [machine compare:@"iPhone5,1"] == NSOrderedSame  // "iPhone5 CDMAV"
//       || [machine compare:@"iPhone5,1"] == NSOrderedSame  // "iPhone5 CDMAS"
       
    {
        return false ;
    }
    
    //iPod Touch
    if([machine compare:@"iPod1,1"] == NSOrderedSame     // "iPod 1G"
       || [machine compare:@"iPod2,1"] == NSOrderedSame  // "iPod 2G"
       || [machine compare:@"iPod3,1"] == NSOrderedSame  // "iPod 3G"
       || [machine compare:@"iPod4,1"] == NSOrderedSame  // "iPod 4G"
//       || [machine compare:@"iPod Touch5,1"] == NSOrderedSame  // "iPod 5G"
       )
    {
        return false ;
    }
    
    //IPad
    if([machine compare:@"iPad1,1"] == NSOrderedSame     // "iPad WiFi"
       || [machine compare:@"iPad1,2"] == NSOrderedSame  // "iPad GSM"
       || [machine compare:@"iPad1,3"] == NSOrderedSame  // "iPad CDMAV"
       || [machine compare:@"iPad1,4"] == NSOrderedSame  // "iPad CDMAS"
//       || [machine compare:@"iPad2,1"] == NSOrderedSame  // "iPad2 WiFi"
//       || [machine compare:@"iPad2,2"] == NSOrderedSame  // "iPad2 GSM"
//       || [machine compare:@"iPad2,3"] == NSOrderedSame  // "iPad2 CDMAV"
//       || [machine compare:@"iPad2,4"] == NSOrderedSame  // "iPad2 CDMAS"
//       || [machine compare:@"iPad2,5"] == NSOrderedSame  // "iPad_MINI WiFi"
//       || [machine compare:@"iPad2,6"] == NSOrderedSame  // "iPad_MINI GSM"
//       || [machine compare:@"iPad2,7"] == NSOrderedSame  // "iPad_MINI CDMA"
//       || [machine compare:@"iPad3,1"] == NSOrderedSame  // "iPad3 Wi-Fi"
//       || [machine compare:@"iPad3,2"] == NSOrderedSame  // "iPad3 GSM"
//       || [machine compare:@"iPad3,3"] == NSOrderedSame  // "iPad3 CDMA"
//       || [machine compare:@"iPad3,4"] == NSOrderedSame  // "iPad4 GSM"
//       || [machine compare:@"iPad3,5"] == NSOrderedSame  // "iPad4 GSM"
//       || [machine compare:@"iPad3,6"] == NSOrderedSame  // "iPad4 CDMA"
    )
    {
        return false ;
    }
       

       
    return true ;

        

}

+ (BOOL)isHigherThanIPhoneX:(NSInteger)aNumber
{
    NSString *platformString = [DeviceInfo platform];
    //  是iPhone并且高于iPhoneX
    return [platformString hasPrefix:@"iPhone"] && [platformString compare:[NSString stringWithFormat:@"iPhone%d", aNumber]] == NSOrderedDescending;
}


+ (BOOL)isHigherThanITouchX:(NSInteger)aNumber
{
    NSString *platformString = [DeviceInfo platform];
    //  是iPad并且高于iPadX
    return [platformString hasPrefix:@"iPod touch"] && [platformString compare:[NSString stringWithFormat:@"iPod touch%d", aNumber]] == NSOrderedDescending;
}

+ (BOOL)isHigherThanIPadX:(NSString *)aNumber
{
    NSString *platformString = [DeviceInfo platform];
    //  是iPad并且高于iPadX
    return [platformString hasPrefix:@"iPad"] && [platformString compare:[NSString stringWithFormat:@"iPad%@", aNumber]] == NSOrderedDescending;
}


+ (NSString *)getBuildOSString{
    NSString *runtimeOSString = [DeviceInfo isBuildForIPad] ? @"iPad" : @"iPhone";
    NSString *simulatorString = @"";
#if TARGET_IPHONE_SIMULATOR
    simulatorString = @" Simulator";
#endif
    NSString *buildOSString = [NSString stringWithFormat:@"%@%@", runtimeOSString, simulatorString];
    return buildOSString;
}
+ (CGFloat)getDeviceSystemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSString *)urlStringToAppStore
{
    if ([DeviceInfo isBuildForIPad]) {
        return @"https://itunes.apple.com/cn/app/id421092396?l=en&mt=8&ls=1";
    }
    else {
        return @"https://itunes.apple.com/cn/app/id462186890?l=en&mt=8&ls=1";
    }
}

+ (NSString *)urlStringToAppStoreCommentPage
{
    if ([DeviceInfo isBuildForIPad]) {
        return @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=421092396&type=Purple+Software";
    }
    else {
        return @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=462186890&type=Purple+Software";
    }
}

+ (NSString *)urlStringToHomePage
{
    if ([DeviceInfo isBuildForIPad]) {
        return @"http://163.fm/ApIduAo";
    }
    else {
        return @"http://163.fm/ZNP26sA";
    }
}

//+ (NSString *)alternateDeviceId;
//{
////    return [UIDevice currentDevice].uniqueIdentifier;
//    NSString *oldId = nil;
//    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//    {
//        oldId = [DESettings getAppUid];
//    }
//    if (oldId == nil)
//    {
//        oldId = [DESettings getDeviceId];
//    }
//    return (oldId == nil) ? @"" : oldId;
//}

+ (NSString *)wifiName
{
    NSString *wifiName = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            wifiName = [dict valueForKey:@"SSID"];
        }
        CFRelease(myArray);
    }
    return wifiName;
}

+ (NSString *)getDeviceName
{
    static NSString *platform = nil;
    if (platform)
        return platform;
    struct utsname systemInfo;
    uname(&systemInfo);
    platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"])    platform = @"iPhone 2G";
    
    else if ([platform isEqualToString:@"iPhone1,2"])    platform =  @"iPhone 3G";
    
    else if ([platform isEqualToString:@"iPhone2,1"])    platform =  @"iPhone 3GS";
    
    else if ([platform isEqualToString:@"iPhone3,1"])    platform =  @"iPhone 4";
    
    else if ([platform isEqualToString:@"iPhone3,2"])    platform =  @"iPhone 4";
    
    else if ([platform isEqualToString:@"iPhone3,3"])    platform =  @"iPhone 4 (CDMA)";
    
    else if ([platform isEqualToString:@"iPhone4,1"])    platform =  @"iPhone 4S";
    
    else if ([platform isEqualToString:@"iPhone5,1"])    platform =  @"iPhone 5";
    
    else if ([platform isEqualToString:@"iPhone5,2"])    platform =  @"iPhone 5 (GSM+CDMA)";
    
    else if ([platform isEqualToString:@"iPhone7,1"])    platform =  @"iPhone 6 Plus";
    
    else if ([platform isEqualToString:@"iPhone7,2"])    platform =  @"iPhone 6";
    
    else if ([platform isEqualToString:@"iPod1,1"])      platform =  @"iPod Touch (1 Gen)";
    
    else if ([platform isEqualToString:@"iPod2,1"])      platform =  @"iPod Touch (2 Gen)";
    
    else if ([platform isEqualToString:@"iPod3,1"])      platform =  @"iPod Touch (3 Gen)";
    
    else if ([platform isEqualToString:@"iPod4,1"])      platform =  @"iPod Touch (4 Gen)";
    
    else if ([platform isEqualToString:@"iPod5,1"])      platform =  @"iPod Touch (5 Gen)";
    
    else if ([platform isEqualToString:@"iPad1,1"])      platform =  @"iPad";
    
    else if ([platform isEqualToString:@"iPad1,2"])      platform =  @"iPad 3G";
    
    else if ([platform isEqualToString:@"iPad2,1"])      platform =  @"iPad 2 (WiFi)";
    
    else if ([platform isEqualToString:@"iPad2,2"])      platform =  @"iPad 2";
    
    else if ([platform isEqualToString:@"iPad2,3"])      platform =  @"iPad 2 (CDMA)";
    
    else if ([platform isEqualToString:@"iPad2,4"])      platform =  @"iPad 2";
    
    else if ([platform isEqualToString:@"iPad2,5"])      platform =  @"iPad Mini (WiFi)";
    
    else if ([platform isEqualToString:@"iPad2,6"])      platform =  @"iPad Mini";
    
    else if ([platform isEqualToString:@"iPad2,7"])      platform =  @"iPad Mini (GSM+CDMA)";
    
    else if ([platform isEqualToString:@"iPad3,1"])      platform =  @"iPad 3 (WiFi)";
    
    else if ([platform isEqualToString:@"iPad3,2"])      platform =  @"iPad 3 (GSM+CDMA)";
    
    else if ([platform isEqualToString:@"iPad3,3"])      platform =  @"iPad 3";
    
    else if ([platform isEqualToString:@"iPad3,4"])      platform =  @"iPad 4 (WiFi)";
    
    else if ([platform isEqualToString:@"iPad3,5"])      platform =  @"iPad 4";
    
    else if ([platform isEqualToString:@"iPad3,6"])      platform =  @"iPad 4 (GSM+CDMA)";
    
    else if ([platform isEqualToString:@"iPad4,1"])      platform =  @"iPad Air (Wi-Fi)";
    
    else if ([platform isEqualToString:@"iPad4,2"])      platform =  @"iPad Air (Cellular)";
    
    else if ([platform isEqualToString:@"iPad4,4"])      platform = @"iPad mini 2G (Wi-Fi)";
    else if ([platform isEqualToString:@"iPad4,5"])      platform = @"iPad mini 2G (Cellular)";
    else if ([platform isEqualToString:@"iPad4,7"])      platform = @"iPad mini 3G (Wi-Fi)";
    else if ([platform isEqualToString:@"iPad4,8"])      platform = @"iPad mini 3G (Cellular)";
    else if ([platform isEqualToString:@"iPad4,9"])      platform = @"iPad mini 3G (Cellular)";
    
    else if ([platform isEqualToString:@"iPad5,3"])      platform =  @"iPad Air 2 (Wi-Fi)";
    
    else if ([platform isEqualToString:@"iPad5,4"])      platform =  @"iPad Air 2 (Cellular)";
    
    else if ([platform isEqualToString:@"i386"])         platform =  @"Simulator";
    
    else if ([platform isEqualToString:@"x86_64"])       platform =  @"Simulator";
    
    else platform =  @"unknow";
    
    return platform;
}

+ (int)getDevicePPI
{
    static int ppi = -1;
    if (ppi >= 0)
        return ppi;
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,2"])    ppi = 163;
    
    else if ([platform isEqualToString:@"iPhone2,1"])    ppi = 163;
    
    else if ([platform isEqualToString:@"iPhone3,1"])    ppi = 326;
    
    else if ([platform isEqualToString:@"iPhone3,2"])    ppi = 326;
    
    else if ([platform isEqualToString:@"iPhone3,3"])    ppi = 326;
    
    else if ([platform isEqualToString:@"iPhone4,1"])    ppi = 326;
    
    else if ([platform isEqualToString:@"iPhone5,1"])    ppi = 326;
    
    else if ([platform isEqualToString:@"iPhone5,2"])    ppi = 326;
    
    else if ([platform isEqualToString:@"iPhone7,1"])    ppi = 401;
    
    else if ([platform isEqualToString:@"iPhone7,2"])    ppi = 326;
    
    else if ([platform isEqualToString:@"iPod1,1"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPod2,1"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPod3,1"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPod4,1"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPod5,1"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPad1,1"])      ppi = 132;
    
    else if ([platform isEqualToString:@"iPad1,2"])      ppi = 132;
    
    else if ([platform isEqualToString:@"iPad2,1"])      ppi = 132;
    
    else if ([platform isEqualToString:@"iPad2,2"])      ppi = 132;
    
    else if ([platform isEqualToString:@"iPad2,3"])      ppi = 132;
    
    else if ([platform isEqualToString:@"iPad2,4"])      ppi = 132;
    
    else if ([platform isEqualToString:@"iPad2,5"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPad2,6"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPad2,7"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPad3,1"])      ppi = 264;
    
    else if ([platform isEqualToString:@"iPad3,2"])      ppi = 264;
    
    else if ([platform isEqualToString:@"iPad3,3"])      ppi = 264;
    
    else if ([platform isEqualToString:@"iPad3,4"])      ppi = 264;
    
    else if ([platform isEqualToString:@"iPad3,5"])      ppi = 264;
    
    else if ([platform isEqualToString:@"iPad3,6"])      ppi = 264;
    
    else if ([platform isEqualToString:@"iPad4,1"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPad4,2"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPad4,4"])      ppi = 163;
    else if ([platform isEqualToString:@"iPad4,5"])      ppi = 163;
    else if ([platform isEqualToString:@"iPad4,7"])      ppi = 163;
    else if ([platform isEqualToString:@"iPad4,8"])      ppi = 163;
    else if ([platform isEqualToString:@"iPad4,9"])      ppi = 163;
    
    else if ([platform isEqualToString:@"iPad5,3"])      ppi = 264;
    
    else if ([platform isEqualToString:@"iPad5,4"])      ppi = 264;
    
    else ppi = 0;
    
    return ppi;
}
@end

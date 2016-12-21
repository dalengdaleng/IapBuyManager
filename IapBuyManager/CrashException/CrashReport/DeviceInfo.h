//
//  DeviceInfo.h
//  PRIS
//
//  Created by huangxiaowei on 10-12-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <JasmineUtil/JasmineUtil.h>

#define kIsRetina4Inch ([[UIScreen mainScreen] bounds].size.height == 568.0)

@interface DeviceInfo : NSObject {

}

//// if running on ipad return YES else return NO (suppose running on iphone).
//+ (BOOL)isIpad;

// if iPad building or not.
+ (BOOL)isBuildForIPad;

// if running on itouch return YES else return NO (suppose running on iphone, or ipad).
+ (BOOL)isItouch;

// used to instead of UIDevice.uniqueIdentify
//+ (NSString *)macDeviceId;
//优先使用AppNewId
//+ (NSString *)realMacDeviceId;

// platform info
//@"iPhone1,1" : @"iPhone 1G";
//@"iPhone1,2" : @"iPhone 3G";
//@"iPhone2,1" : @"iPhone 3GS";
//@"iPhone3,1" : @"iPhone 4 GSM";
//@"iPhone4,1" : @"iPhone 4s";
//@"iPhone5,1" : @"iPhone 5";

//@"iPod1,1" : @"iPod Touch 1G";
//@"iPod2,1" :  @"iPod Touch 2G";
//@"iPod3,1" : @"iPod Touch 3G";
//@"iPod4,1" : @"iPod Touch 4G";
//@"iPod5,1" : @"iPod Touch 5G"

//@"iPad1,1" : @"iPad";
//@"iPad2,1" : @"iPad 2"
//@"iPad2,5" : @"iPad mini"
//@"iPad3,1" : @"iPad 3"
//@"iPad3,4" : @"iPad 4"

//@"i386" :  @"Simulator";
+ (NSString *)platform;
//  判断设备是iPhone并且高于某一个级别
+ (BOOL)isHigherThanIPhoneX:(NSInteger)aNumber;
//  判断设备是iPad并且高于某一个级别
+ (BOOL)isHigherThanIPadX:(NSString *)aNumber;
//  用于判断是一个高性能的机器
+ (BOOL)isHighPerformance;
+ (NSString *)getBuildOSString;
+ (CGFloat)getDeviceSystemVersion;


+ (NSString *)urlStringToAppStore;
+ (NSString *)urlStringToHomePage;
+ (NSString *)urlStringToAppStoreCommentPage;

// deviceId alternative
//+ (NSString *)alternateDeviceId;

+ (NSString *)wifiName;
+ (NSString *)getDeviceName;
+ (int)getDevicePPI;

@end

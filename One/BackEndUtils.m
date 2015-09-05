/*
 * File : WMOMBackEndUtils.m
 * Project : Wemoms
 *
 * Description : App delegate
 *
 * DRI : Laurent Cerveau
 * Created : 2015/02/18
 * Copyright (c) 2013 - 2015 Globalia. All rights reserved. *
 */

@import Foundation;
@import UIKit;

#import <sqlite3.h>
#import <CommonCrypto/CommonHMAC.h>

#import "BackEndUtils.h"

#import "ConstantUtils.h"
#import "OneLogger.h"

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@implementation BackEndUtils

/* Directory creation : check there is no file with the same name, if yes remove it, create create directory if not present */
BOOL EnsureDirectoryAtPath(NSString *dirPath)
{
    BOOL result = NO;
    NSError	*error = nil;
    BOOL	isDirectory = NO;
    BOOL	cacheExists = NO;
    
    cacheExists = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDirectory];
    if ((cacheExists == YES) && (isDirectory == NO)){
        /* It is not a directory. Remove it. */
        if ([[NSFileManager defaultManager] removeItemAtPath:dirPath error:&error] == NO) {
            OneLog(LOCALLOGENABLED,@" --> can not remove file that is here instead of directory ");
            return result;
        } else {
            cacheExists = NO;
        }
    }
    /* Now we can safely create the cache directory if needed. */
    if (cacheExists == NO){
        if ([[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            OneLog(LOCALLOGENABLED,@" --> Could not create directory %@ ", dirPath);
        } else {
            result = YES;
        }
    }
    
    return result;
}


/* Convert 1.0.3 to 103 and 1.0 to 100 */
int UtilityConvertMarketingVersionTo3Digit(NSString *version)
{
    NSMutableArray *componentArray = [NSMutableArray arrayWithArray:[version componentsSeparatedByString:@"."]];
    for(NSUInteger idx = [componentArray count]; idx < 3; idx++) {
        [componentArray addObject:@0];
    }
    __block int result = 0;
    [componentArray enumerateObjectsUsingBlock:^(NSString *aComponent, NSUInteger idx, BOOL *stop) {
        result = 10*result+[aComponent intValue];
    }];
    return result;
}


/* Get a MD5 from a string */
NSString *MD5FromString(NSString *input)
{
    // usefull for debugging caching
    // keep it !
    
    //    NSString *result = [input stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    //    result = [result stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    //    return [NSString stringWithFormat:@"%@.png", result];
    
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG) (strlen(cStr)), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

// Iteratively remove null from dictionnary
NSDictionary *dictionaryByRemovingNulls(NSDictionary *dictionnary) {
    const NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:dictionnary];
    const id nul = [NSNull null];
    
    for (NSString *key in dictionnary) {
        const id object = [dictionnary objectForKey: key];
        if (object == nul) {
            [replaced removeObjectForKey: key];
        }
        else if ([object isKindOfClass: [NSDictionary class]]) {
            [replaced setObject: dictionaryByRemovingNulls(object) forKey: key];
        }
        else if ([object isKindOfClass: [NSArray class]]) {
            [replaced setObject: arrayByRemovingNulls(object) forKey: key];
        }
    }
    return (NSDictionary *)replaced;
}

// Iteratively remove null from nsarray
NSArray *arrayByRemovingNulls(NSArray *array) {
    const NSMutableArray *replaced = [NSMutableArray arrayWithArray:array];
    const id nul = [NSNull null];
    
    for(int i = 0; i < replaced.count; i++)
    {
        id object = [replaced objectAtIndex:i];
        if (object == nul) {
            [replaced removeObject:object];
        }
        else if ([object isKindOfClass: [NSDictionary class]]) {
            [replaced removeObject:object];
            [replaced insertObject: dictionaryByRemovingNulls(object) atIndex:i];
        }
        else if ([object isKindOfClass: [NSArray class]]) {
            [replaced removeObject:object];
            [replaced insertObject:arrayByRemovingNulls(object) atIndex:i];
        }
    }
    return (NSArray *)replaced;
}

@end

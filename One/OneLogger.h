/*
 *  OneLogger.h
 *  Project : Wemoms
 *
 *  Description : Centralized log system
 *
 *  DRI     : Laurent Cerveau
 *  Created : 2014/09/12
 *  Copyright (c) 2014-2015 Globalis. All rights reserved.
 *
 */

@import Foundation;

__BEGIN_DECLS
/* Core logging function */
void OneLogInternal(BOOL doLog,const char *filename, unsigned int line, NSString *format, ...);
__END_DECLS

#define OneLog(doLog, ...) OneLogInternal(doLog, __FILE__, __LINE__, __VA_ARGS__)

//Atom constants
extern NSString *const kOneLogAtomTypeKey;      //@"HTTP", @"NOTI", @"APPL"
extern NSString *const kOneLogAtomTypeHTTPValue;
extern NSString *const kOneLogAtomTypeDeviceValue;
extern NSString *const kOneLogAtomTypeNotificationValue;
extern NSString *const kOneLogAtomTypeApplicationValue;
extern NSString *const kOneLogAtomStartDateKey;
extern NSString *const kOneLogAtomMethodKey;
extern NSString *const kOneLogAtomEndPointKey;
extern NSString *const kOneLogAtomMessageKey;       //Used instead of Message in APPL and NOTI
extern NSString *const kOneLogAtomParametersKey;
extern NSString *const kOneLogAtomAppStateKey;
extern NSString *const kOneLogAtomStatusKey;
extern NSString *const kOneLogAtomDurationKey;
extern NSString *const kOneLogAtomServerDurationKey;
extern NSString *const kOneLogAtomServerMessageKey;



// OneLogOptions
typedef enum
{
    kOneLogOptionsNone =  0,
    kOneLogOptionsRunLog = 1 << 1, 	//If this option is used , log will be written to a file in addition to the console
    kOneLogOptionsSendToTestFlight =  1 << 2,

} OneLogOptions;


// OneLogger
@interface OneLogger : NSObject
{
    NSString *_identifier;
    NSString *_deviceModel;
    NSString *_deviceOS;

    NSString *_pathToRunLogFolder;
    NSString *_currentLogName;

    NSMutableDictionary *_logAtoms;
}

@property (nonatomic, assign) OneLogOptions logOptions;
@property(nonatomic,strong) NSString         *pathToRunLogFolder;
@property(nonatomic,strong) NSString         *currentLogName;
@property(nonatomic,assign) BOOL         logAtomEnabled;


/* Singleton access */
+ (instancetype)defaultLogger;

/* Provides back a list of saved logs : that is the one saved when kOneLogOptionsRunLog is there */
- (NSArray *)savedLogNames;

/* Will remove all logs from the log folder */
- (void)deleteLogs;

/* Provides back the full content of a log */
- (NSString *)contentOfLogWithName:(NSString *)logName;

/* Log atoms catch events */
- (NSArray *)allLogAtoms;

/* Returns and HTML representation of the atoms */
- (NSString *)allAtomsHTMLRepresentation;

/* Will create and store one atoms */
- (NSString *)logAtomWithData:(NSDictionary *)data forUUID:(NSString *)uuid;

/* Log atoms catch events */
- (void)deleteAllLogAtoms;

@end

/*
 * File : BackEndUtils.h
 *
 * Description : App delegate
 *
 */
@import UIKit;
@import Foundation;

/* Directory creation : check there is no file with the same name, if yes remove it, create create directory if not present */
BOOL EnsureDirectoryAtPath(NSString *dirPath);

/* UniqueEndPath */
NSString *EndPointUniqueEndPath(NSString *fullURLString);

/* Get displayable elapsed time from Date */
BOOL EnsurePersistentSQLDatabaseAtDirectory(NSString *path, int version, NSArray *classesArray);

/* Convert 1.0.3 to 103 and 1.0 to 100 */
int UtilityConvertMarketingVersionTo3Digit(NSString *version);

/* Get a MD5 from a string */
NSString *MD5FromString(NSString *input);

// Iteratively remove null from dictionnary
NSDictionary *dictionaryByRemovingNulls(NSDictionary *dictionnary);

// Iteratively remove null from nsarray
NSArray *arrayByRemovingNulls(NSArray *array);

@interface BackEndUtils : NSObject

@end

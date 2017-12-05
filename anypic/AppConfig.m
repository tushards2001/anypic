//
//  AppConfig.m
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "AppConfig.h"
#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"

@implementation AppConfig

static AppConfig *sharedHelper = nil;

+(AppConfig *) sharedInstance
{
    
    if (!sharedHelper)
    {
        sharedHelper = [[AppConfig alloc] init];
    }
    
    return sharedHelper;
}

-(id)init
{
    if( (self=[super init]))
    {
        NSLog(@"AppConfig init()");
    }
    
    return self;
}

- (NSDate *)getDateFromStringWithDateFormat:(NSString *)dateFormatString dateString:(NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormatString];
    //NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:[[NSTimeZone localTimeZone] name]];
    [formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:dateString];
    
    return date;
}



#pragma mark - Unsplash API Methods

- (void)UnsplashSearchPhotoByKeyword:(NSString *)keyword page:(int)page
{
    NSString *postURL = [NSString stringWithFormat:@"%@/search/photos?page=1&query=%@&client_id=%@&per_page=%d&page=%d", API_URL, keyword, APP_ID, RESULTS_PER_PAGE, page];
    
    NSLog(@"postURL = %@", postURL);
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:postURL]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:TIMEOUT_INTERVAL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    if (error)
                                                    {
                                                        NSLog(@"Error,%@", [error localizedDescription]);
                                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                                                        [userInfo setObject:[error localizedDescription] forKey:@"error"];
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"UnsplashSearchErrorNotification"
                                                                                                            object:0
                                                                                                          userInfo:userInfo];
                                                    }
                                                    else
                                                    {
                                                        NSError *jsonError;
                                                        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                        
                                                        if (jsonError)
                                                        {
                                                            NSLog(@"***jsonError\n%@", [jsonError localizedDescription]);
                                                            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                                                            [userInfo setObject:[jsonError localizedDescription] forKey:@"error"];
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"UnsplashSearchErrorNotification"
                                                                                                                object:nil
                                                                                                              userInfo:userInfo];
                                                        }
                                                        else
                                                        {
                                                            // Success Parsing JSON
                                                            // Log NSDictionary response:
                                                            //NSArray *arrayResult = [jsonResponse objectForKey:@"results"];
                                                            //NSLog(@"Total Pages: %@", [jsonResponse objectForKey:@"total_pages"]);
                                                            //NSLog(@"Total Photos: %@", [jsonResponse objectForKey:@"total"]);
                                                            //NSLog(@"Results = %@", [jsonResponse objectForKey:@"results"]);
                                                            
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"UnsplashSearchResultNotification"
                                                                                                                object:nil
                                                                                                              userInfo:[jsonResponse dictionaryByReplacingNullsWithBlanks]];
                                                        }
                                                    }
                                                }];
    [dataTask resume];
}

- (void)authorizeApp
{
    NSString *postURL = [NSString stringWithFormat:@"https://api.unsplash.com/photos/?client_id=%@", APP_ID];
    
    NSURL *url = [NSURL URLWithString:postURL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    if (error)
                                                    {
                                                        NSLog(@"Error,%@", [error localizedDescription]);
                                                    }
                                                    else
                                                    {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"status code = %ld", (long)httpResponse.statusCode);
                                                        
                                                        if ([response isKindOfClass:[NSHTTPURLResponse class]])
                                                        {
                                                            NSError *jsonError;
                                                            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                            
                                                            if (jsonError)
                                                            {
                                                                NSLog(@"jsonError,%@", [jsonError localizedDescription]);
                                                            }
                                                            else
                                                            {
                                                                // Success Parsing JSON
                                                                // Log NSDictionary response:
                                                                NSLog(@"%@",jsonResponse);
                                                            }
                                                        }
                                                        else
                                                        {
                                                            NSLog(@"Error");
                                                        }
                                                    }
                                                }];
    [dataTask resume];
}



#pragma mark - FileManager

- (BOOL)collectionPLISTCreated
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", COLLECTION_PLIST]];
    
    if ([FCFileManager isFileItemAtPath:path])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)createCollectionPLIST
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", COLLECTION_PLIST]];
    NSLog(@"path = %@", path);
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    NSMutableArray *collection = [[NSMutableArray alloc] init];
    [data setObject:collection forKey:@"collection"];
    
    if ([data writeToFile:path atomically:YES])
    {
        return YES;
    }
    else
    {
        NSLog(@"Error creating %@ file", COLLECTION_PLIST);
        return NO;
    }

    
}

- (NSDictionary *)getCollectionPLISTData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", COLLECTION_PLIST]];
    
    
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:path];
    return data;
}

- (BOOL)addDataToCollectionPLIST:(NSDictionary *)dictionary
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", COLLECTION_PLIST]];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"collection"]];
    [array addObject:dictionary];
    [data setObject:array forKey:@"collection"];
    //NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self getCollectionPLISTData]];
    //NSLog(@"array[%ld] = %@", array.count, array);
    //[array addObject:data];
    
    NSError *error;
    //check if file exists
    if ([FCFileManager isFileItemAtPath:path])
    {
        if ([data writeToFile:path atomically:YES])
        {
            NSLog(@"DATA WRITTEN SUCCESSFULLY TO %@", COLLECTION_PLIST);
            // %@", data);
            return YES;
        }
        else
        {
            NSLog(@"Error writing to %@ file:\n%@", COLLECTION_PLIST, error.localizedDescription);
            return NO;
        }
    }
    else
    {
        NSLog(@"FILE DOES NOT EXIST");
        return NO;
    }
    
}

- (BOOL)saveImage:(UIImage *)image imageId:(NSString *)imageId suffix:(NSString *)suffix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_%@.jpg", imageId, suffix]];
    
    NSData *pngData = UIImageJPEGRepresentation(image, 1.0);
    
    return [pngData writeToFile:path atomically:YES];;
}

- (UIImage *)getImageById:(NSString *)imageId suffix:(NSString *)suffix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_%@.jpg", imageId, suffix]];
    
    NSData *pngData = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:pngData];
    
    return image;
}


@end

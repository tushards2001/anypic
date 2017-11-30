//
//  AppConfig.m
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "AppConfig.h"

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

- (void)UnsplashSearchPhotoByKeyword:(NSString *)keyword
{
    NSString *postURL = [NSString stringWithFormat:@"%@/search/photos?page=1&query=%@&client_id=%@&per_page=%d", API_URL, keyword, APP_ID, RESULTS_PER_PAGE];
    
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
                                                                                                            object:nil
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
                                                            NSArray *arrayResult = [jsonResponse objectForKey:@"results"];
                                                            NSLog(@"Total Pages: %@", [jsonResponse objectForKey:@"total_pages"]);
                                                            NSLog(@"Total Photos: %@", [jsonResponse objectForKey:@"total"]);
                                                            NSLog(@"Results[%ld]", arrayResult.count);
                                                            
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"UnsplashSearchResultNotification"
                                                                                                                object:nil
                                                                                                              userInfo:jsonResponse];
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

@end

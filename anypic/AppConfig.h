//
//  AppConfig.h
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_URL @"https://api.unsplash.com"
#define APP_ID @"a5e80eed737d54063287305f2b9dfd118e5b13092af3d9dd7068a3c3887b39ac"
#define RESULTS_PER_PAGE 30
#define TIMEOUT_INTERVAL 10.0
#define IMAGES_PER_ROW 3

@interface AppConfig : NSObject
{
    
}

+(AppConfig *)sharedInstance;


- (id)init;

- (NSDate *)getDateFromStringWithDateFormat:(NSString *)dateFormatString dateString:(NSString *)dateString;

#pragma mark - Unsplash API Methods

- (void)UnsplashSearchPhotoByKeyword:(NSString *)keyword page:(int)page;
- (void)authorizeApp;

@end

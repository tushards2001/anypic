//
//  AppConfig.h
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FCFileManager/FCFileManager.h>
#import <Photos/Photos.h>

#define API_URL @"https://api.unsplash.com"
#define APP_ID @"a5e80eed737d54063287305f2b9dfd118e5b13092af3d9dd7068a3c3887b39ac"
#define RESULTS_PER_PAGE 30
#define TIMEOUT_INTERVAL 10.0
#define IMAGES_PER_ROW 3
#define COLLECTION_PLIST @"collection.plist"
#define SEGUE_TYPE_SAVED @"saved"
#define SEGUE_TYPE_ONLINE @"online"

@interface AppConfig : NSObject
{
    
}

+(AppConfig *)sharedInstance;


- (id)init;

- (NSDate *)getDateFromStringWithDateFormat:(NSString *)dateFormatString dateString:(NSString *)dateString;

#pragma mark - Unsplash API Methods

- (void)UnsplashSearchPhotoByKeyword:(NSString *)keyword page:(int)page;
- (void)authorizeApp;



#pragma mark - FileManager

- (BOOL)collectionPLISTCreated;
- (BOOL)createCollectionPLIST;
- (NSDictionary *)getCollectionPLISTData;
- (BOOL)addDataToCollectionPLIST:(NSDictionary *)dictionary;
- (BOOL)saveImage:(UIImage *)image imageId:(NSString *)imageId suffix:(NSString *)suffix;
- (UIImage *)getImageById:(NSString *)imageId suffix:(NSString *)suffix;

@end
